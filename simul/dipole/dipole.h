/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   dipole.h
 * @brief  Simulation of magnetic dipole in solar wind.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DIPOLE_CAM_H__
#define __SAT_DIPOLE_CAM_H__

#include "sat.h"

#define BASE(var) ((TBase*)this)->var

/**
 * @brief Simulation of magnetic dipole in solar wind.
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class DipoleCAMCode : public CAMCode<DipoleCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<DipoleCAMCode<T,D>,T,D> TBase;
  typedef Particle<T,D> TParticle;
  typedef typename TBase::TSpecie TSpecie;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;
  typedef typename TBase::PosVector PosVector;
  typedef typename TBase::FldVector FldVector;
  typedef typename TBase::VelVector VelVector;

  /// @brief Parse the configuration file arguments before CAM code does.
  /// @param cfg Root of configuration file.
  virtual void PreInitialize (const ConfigFile &cfg);

  /// @brief Initialize application after CAM code does.
  /// @param cfg Root of configuration file.
  virtual void PostInitialize (const ConfigFile &cfg);

  bool PcleBCAdd (TSpecie *sp, size_t id, TParticle &pcle)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = (pcle.pos[i] + _ip[i]*_nc[i]) * _dx[i] - _cx[i];

    T dist2 = xp.Norm2 ();
    if ((dist2 < _radius2) && BASE(_time).Iter() == 0)
    {
      sp->Exec (id, PCLE_CMD_REMOVE);
      return true;
    }

    if (dist2 < _radius2)
    {
      VelVector vp = pcle.vel;

      T a = vp[0]*vp[0] + vp[1]*vp[1];
      T b = -2.*(xp[0]*vp[0] + xp[1]*vp[1]);
      T c = xp[0]*xp[0] + xp[1]*xp[1] - _radius2;
      T dtc = (-b + Math::Sqrt(b*b - 4.*a*c))/(2.*a);

      /// Position where pcle crossed the surface
      VelVector xpc;
      xpc.Set (xp);
      xpc -= dtc*vp;

      /// Angle of rotation of Z-axis
      T phiz = Math::ATan2 (xpc[0],xpc[1]);
      ZRotMatrix3<T> rotz (phiz);
      ReversibleTransform<T> trans (rotz, xpc);

      VelVector vpu, xpu;

      vpu.Set (vp);
      vpu = trans.Other2ThisRelative (vpu);
      vpu[1] = -vpu[1];
      vpu = trans.This2OtherRelative (vpu);

      xpu.Set (xp);
      xpu = trans.Other2This (xpu);
      xpu[1] = -xpu[1];
      xpu = trans.This2Other (xpu);

      pcle.vel = vpu;
      for (int i=0; i<D; ++i)
        pcle.pos[i] = (xp[i] + _cx[i]) * _dxi[i] - _ip[i]*_nc[i];
    }
    else if (dist2 < _radius2*(1.5*1.5))
    {
      VelVector u;
      CartStencil::BilinearWeight (BASE(_U), pcle.pos, u);

      T mask = T(1), ee = (xp.Norm()-_radius) * _plbcleni;
      if (ee < T(10))
	mask = T(1) - Math::Exp (-ee*ee);

      /// Angle of rotation of Z-axis
      T phiz = atan2(xp[0],xp[1]);
      ZRotMatrix3<T> rotz (phiz);
      ReversibleTransform<T> trans (rotz, u);
      u = trans.Other2ThisRelative (u);
      u[1] *= mask;
      u = trans.This2OtherRelative (u);

      pcle.vel -= u;
    }

    return false;
  }

  void EfieldAdd ()
  {
    DomainIterator<D> ite;
    BASE(_E).GetDomainIterator (ite, false);
    PosVector xp;
    do
    {
      xp = ite.GetPosition ();
      xp -= _cx;

      if (xp.Norm2() < _radius2)
        BASE(_E)(ite) = 0.;
    }
    while (ite.Next());
  }

  bool EcalcAdd (const DomainIterator<D> &ite)
  {
    PosVector xp = ite.GetPosition ();
    xp -= _cx;

    // Don't update electric field inside of the planet
    if (xp.Norm2 () < _radius2)
      return true;

    return false;
  }

  bool BcalcAdd (const DomainIterator<D> &itb)
  {
    PosVector xp = itb.GetPosition ();
    xp -= _cx;

    // Don't update magnetic field inside of the planet
    if (xp.Norm2() < _radius2)
      return true;

    return false;
  }

  void BInitAdd (VecField &b)
  {
    _nc=0.; _ip=0.; _cx=0.; _dx=0.; _dxi=0.;
    FldVector ulf, bdip, np=0., lx=0.;
    PosVector xp;
    for (int i=0; i<D; ++i)
    {
      _nc[i] = b.Size(i)-1;
      np[i] = b.GetLayout().GetDecomp().GetSize(i);
      _ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
      _dx[i] = b.GetMesh().GetResol(i);
      _dxi[i] = 1./_dx[i];
      lx[i] = _nc[i] * np[i] * _dx[i];
      _cx[i] = lx[i] * _rpos[i];
    }

    DomainIterator<D> it;
    b.GetDomainIteratorAll (it, false);
    do
    {
      xp = it.GetPosition ();
      xp -= _cx;

      CalcDipole (xp, bdip);
      CalcUlfWave (xp, ulf);
      b(it) += bdip;
      b(it) += ulf;
    }
    while (it.Next());
  }

  T ResistAdd (const DomainIterator<D> &iter) const
  {
    PosVector xp = iter.GetPosition ();
    xp -= _cx;

    T am = 0.8 - BASE(_resist);
    T ee = (xp.Norm()-_radius) * _plbcleni;
    if (ee < T(10))
      return am*Math::Exp (-ee*ee);
    else
      return T(0);
  }

  T BmaskAdd (const DomainIterator<D> &itb)
  {
    T mask = T(1);

    if (_plbcleni < T(0))
      return mask;

    PosVector xp = itb.GetPosition ();
    xp -= _cx;

    T ee = (xp.Norm()-_radius) * _plbcleni;
    if (ee < T(10))
      mask = (T)1. - Math::Exp (-ee*ee);

    return mask;
  }

  T EmaskAdd (const DomainIterator<D> &ite)
  { return BmaskAdd (ite); }

  void DnInitAdd (TSpecie *sp, ScaField &dn)
  {
    PosVector xp;
    DomainIterator<D> it;
    dn.GetDomainIteratorAll (it, false);

    do
    {
      xp = it.GetPosition ();
      xp -= _cx;

      if (xp.Norm2 () < _radius2)
        dn(it) = 0.;

      dn(it) = CalcDn (sp, xp);
    }
    while (it.Next());
  }

  T CalcDn (TSpecie *sp, const PosVector &xp)
  {
    if (sp->GetName () == "solarwind")
      return CalcDnSolarWind (sp, xp);
    else if (sp->GetName () == "ionosphere")
      return CalcDnIonosphere (sp, xp);
    else
      return 1.;
  }

  T CalcDnSolarWind (TSpecie *sp, const PosVector &xp)
  {
    /// Tangential profile of ionospheric particles
    // T dist = xp.Norm ()/_radius;
    // T nsurf = 100.;
    // T gamma = 6.;

    // if (.98 < dist)
    //   return 1. + (nsurf-1.)/Math::Pow (dist, gamma);
    // else
    return 1.;
  }

  T CalcDnIonosphere (TSpecie *sp, const PosVector &xp)
  {
    /// Tangential profile of ionospheric particles
    T ld = _radius / 2;
    T rm = _radius / 2.;
    T am = 2.0;
    T ee = xp.Norm()-_radius;

    return am*(Math::ATan ((-ee+ld)/rm)/M_PI+0.5);
  }

  void CalcUlfWave (const PosVector &xp, FldVector &ulf)
  {
    ulf = T(0);
    if (!_ulfenable)
      return;

    // actual angle from equator
    T lambda = Math::ATan2 (xp[0], Math::Abs (xp[1]));
    T coslam = Math::Cos (lambda);
    if (Math::Abs (coslam) < M_EPS)
      return;

    T amp;
    T r0 = xp.Norm () / (coslam*coslam);
    T ee = Math::Abs (_ulfdist - r0) / _ulfwidth;
    if (ee < T(10))
      amp = _ulfamp * Math::Exp (-ee*ee);
    else
      return;

    // lambda angle where field line enters planet
    T lamp = Math::ACos (Math::Sqrt (_radius/_ulfdist));
    // relative angle -pi pi at surface of planet
    T rellam = lambda / lamp * M_PI_2;
    ulf[2] = amp * Math::Sin (rellam);
  }

  /// Calculate dipole field adjusted to keep plasma in equilibrium
  /// B = Bv (1-beta_vacuum/2)
  void CalcDipole (const PosVector &relpos, FldVector &bdip)
  {
    T p0, betav;
    CalcDipoleVacuum (relpos, bdip);

    // CalcPressure0 (NULL, relpos, p0);
    // betav = 2.*p0 / bdip.Norm2 ();

    // bdip *= 1. - betav / 2.;
  }

  /// Calculate pressure on the equator from given position
  /// Note that pressure is constant along the field line.
  void CalcPressure0 (TSpecie *sp, const PosVector &relpos, T &p0)
  {
    PosVector pos = 0.;
    SAT_ASSERT (D == 2);

    if (relpos.Norm2 () > _radius2*0.8*0.8)
    {
      FldVector bdip;
      pos[0] = CalcR0 (sp, relpos[0], relpos[1]);
      T beta = CalcBeta (sp, pos[0]);
      CalcDipoleVacuum (pos, bdip);
      p0 = beta * bdip.Norm2 () / 2.;
    }
    else
      p0 = 0.;
  }

  T CalcBeta (TSpecie *sp, T dist)
  {
    if (sp == NULL)
      return BASE(_betai);
    else
      return sp->Beta ();
  }

  /// Calculate mg. field of point dipole (in vacuum)
  void CalcDipoleVacuum (const PosVector &relpos, FldVector &bdip)
  {
    FldVector xp = 0., mv = 0.;
    xp.Set (relpos);
    // Set minimal radius at 80% of _radius, under which we dont calculate
    // dipole field since it is not necessary anyway and cases it problems in
    // variable outputs and FPEs.
    const T r3min = _radius2*0.8*0.8 * _radius*0.8;
    mv[D-1] = -_amp;

    T r3 = xp.Norm() * xp.Norm2();
    xp.Normalize();

    if (r3 > r3min)
      bdip = ((T)3.*(mv*xp) * xp - mv)/r3;
    else
      bdip = ((T)3.*(mv*xp) * xp - mv)/r3min;
  }

  double CalcR0 (TSpecie *sp, double R, double Z)
  {
    double alpha = 6.;
    double beta = CalcBeta (sp, R);

    double R2 = R*R;
    double Z2 = Z*Z;
    double psi0 = R2/Math::Pow (R2+Z2,double(3./2.));
    double betac = beta / (2.*(alpha-1.));

    double rarius = Math::Sqrt (R2 + Z2);
    double lambda = Math::ATan (Z / R);
    double sinlam = Math::Sin (lambda);

    double a, b, c;
    a = psi0;
    b = -(1.+betac);
    c = betac*rarius*rarius*rarius*R2/(1. + 3.*sinlam*sinlam);

    if (Math::Abs (Math::Abs (lambda) - M_PI_2) > M_PI/100.)
      return SolvePoly (a, b, c, rarius*rarius*rarius);
    else
      return 1000.;
  }

  /// Solve "ax^6 + bx^5 + c = 0)
  /// x value is an initial guess
  double SolvePoly (double a, double b, double c, double x_start)
  {
    int iter = 0, max_iter = 100;
    double f, df, x0, x = x_start;

    do
    {
      const double x2 = x*x;
      const double x4 = x2 * x2;
      f = a* x4*x2 + b* x4*x + c;
      df = 6.*a* x4*x + 5.*b* x4;
      x0 = x;
      x = x - f/df;
      iter++;
    }
    while (iter < max_iter && fabs (x-x0) > fabs(x)*1e-5);

    return x;
  }

private:
  CosRandGen<T> _thtgen;
  RandomGen<T> _rand;
  MaxwellRandGen<T> _maxwplnorm;

  // ULF source
  bool _ulfenable;
  T _ulfamp, _ulfomega, _ulfdist, _ulfwidth;

  // Planet configuration
  bool _dipole;
  T _plbcleni;
  T _vthplnorm;
  T _amp, _radius, _radius2;
  Vector<T,D> _rpos, _nc, _ip, _cx, _dx, _dxi;
};

#include "init.cpp"

#endif /* __SAT_DIPOLE_CAM_H__ */


/// Reset tangential component of E field at the surface
// T ld = 1.;
// T ee = (xp.Norm()-_radius)/ld;
// T ta = (T)1. - Math::Exp (-ee*ee*ee);
// T na;
// FldVector nv, tv, ef = _E(ite);
// xp.Normalize ();
// na = xp * ef;
// nv = xp * na;
// tv = ef - nv;


/// Exponential resistivity
// T ld = 4.0;
// T ee = (cp.Norm()-_radius)/ld;
// return Math::Exp (-ee * ee);


/// Emit particle at random place of the night side
// if (dist2 < _radius2*(1.01*1.01))
// {
//   bool repeat;
//   do
//   {
//     repeat = false;
//     T ang = M_2PI*_rand.Get ();// - M_PI_2;
//     T rr = _radius * (1.01 + .2*_rand.Get ());
//     xp[0] = rr * Math::Cos (ang) + _cx[0];
//     xp[1] = rr * Math::Sin (ang) + _cx[1];
//     for (int i=0; i<D; ++i)
//     {
//       pcle.pos[i] = (xp[i]/_dx[i] - _ip[i]*_nc[i]);
//       if (pcle.pos[i] <= ((TBase*)this)->_pmin[i] ||
//           ((TBase*)this)->_pmax[i] <= pcle.pos[i])
//         repeat = true;
//     }
//   }
//   while (repeat);

//   xp.Normalize (Math::Abs (T(2.)+_maxw.Get ()));
//   pcle.vel[0] = xp[0];
//   pcle.vel[1] = xp[1];
//   pcle.vel[2] = 0.;
// }


    /*
   /// Reflect particle from the surface with random velocity smaller then the
   /// original one
   if (dist2 < _radius2*(.99 * .99))
   {
   const T maxw1 = _maxwplnorm.Get ();
   const T maxw2 = _maxwplnorm.Get ();

   pcle.vel.Set (xp);
   pcle.vel.Normalize (Math::Sqrt (maxw1*maxw1 + maxw2*maxw2));
   }
    */



  /*
 /// Random particle injection from the surface of the planet
 void InjectAdd (TSpecie *sp)
 {
 // if (sp->GetName () != "ionosphere")
 //   return;

 const T injdn = 10.0;

 const T ngpcles = sp->InitalPcles ();
 const T drinj = _vthplnorm * BASE(_time).Dt ();
 const T radinj = _radius + drinj;
 const T radius = _radius + _rand.Get () * drinj;

 T shellvol;
 if (D == 1)
 shellvol = T(2.) * (radinj - _radius);
 else if (D == 2)
 shellvol = T(M_PI) * (radinj*radinj - _radius2);
 else
 shellvol = T(4./3.*M_PI) * (radinj*radinj*radinj - _radius2*_radius);

 static T plinjpcle = 0.;
 plinjpcle += injdn * ngpcles * shellvol / _dx.Mult ();

 TParticle pcle;
 FldVector bdip;
 PosVector pos;
 size_t pid;
 T u,v,tht,phi;
 T sinphi, cosphi, sintht, costht;
 while (plinjpcle > 1.)
 {
 plinjpcle--;

 u = _rand.Get ();
 v = _rand.Get ();
 phi = u * M_2PI;
 tht = v * M_PI; // Math::ACos (2.*v - 1.); // increase # pcles at poles
 sinphi = Math::Sin (phi);
 cosphi = Math::Cos (phi);
 sintht = Math::Sin (tht);
 costht = Math::Cos (tht);

 if (D >= 1)
 {
 pos[0] = radius*sintht*cosphi;
 pcle.pos[0] = _dxi[0]*(pos[0] + _cx[0]) - _ip[0]*_nc[0];
 if (pcle.pos[0] < BASE(_pmin)[0] || BASE(_pmax)[0] < pcle.pos[0])
 continue;
 }

 if (D >= 2)
 {
 pos[1] = radius*sintht*sinphi;
 pcle.pos[1] = _dxi[1]*(pos[1] + _cx[1]) - _ip[1]*_nc[1];
 if (pcle.pos[1] < BASE(_pmin)[1] || BASE(_pmax)[1] < pcle.pos[1])
 continue;
 }

 if (D >= 3)
 {
 pos[2] = radius*costht;
 pcle.pos[2] = _dxi[2]*(pos[2] + _cx[2]) - _ip[2]*_nc[2];
 if (pcle.pos[2] < BASE(_pmin)[2] || BASE(_pmax)[2] < pcle.pos[2])
 continue;
 }

 // Add theta angle with cos distribution
 CalcDipole (pos, bdip);
 bdip.Normalize ();
 if (pos[D-1] > 0.)
 bdip *= -1.; // change orientation to outwards

 if (D == 3)
 phi = Math::ATan2 (pos[0], pos[1]);
 else
 phi = 0.;
 tht = Math::ACos (bdip[D-1]);
 tht += _thtgen.Get ();

 sinphi = Math::Sin (phi);
 cosphi = Math::Cos (phi);
 sintht = Math::Sin (tht);
 costht = Math::Cos (tht);

 pcle.vel[0] = sintht*cosphi;
 pcle.vel[1] = sintht*sinphi;
 pcle.vel[2] = costht;

 // Rotate around local axis by (0, 2Pi>
 FldVector axis;
 axis.Set (pos);
 Quaternion<T> q (axis, M_2PI * _rand.Get ());
 pcle.vel = q.Rotate (pcle.vel);

 // Normalize velocity to random Maxwell DF with vth = dipole.vthnorm
 const T maxw1 = _maxwplnorm.Get ();
 const T maxw2 = _maxwplnorm.Get ();
 //      pcle.vel.Set (pos);
 pcle.vel.Normalize (Math::Sqrt (maxw1*maxw1 + maxw2*maxw2));

 pid = sp->Push (pcle);
 sp->Exec (pid, PCLE_CMD_ARRIVED);
 }
 }
  */




  // bool EcalcSrc (const DomainIterator<D> &ite, FldVector &efsrc)
  // {
  //   /// Apply ULF source in equator plane
  //   if (!_ulfenable)
  //     return false;

  //   PosVector xp = ite.GetPosition ();
  //   xp -= _cx;

  //   T tht = Math::ATan (xp[1]/xp[0]) / (M_PI/15.);
  //   if (tht > 5.)
  //     return false;

  //   T dis = (_ulfdist - Math::Abs (xp[0])) / _ulfwidth;
  //   if (dis > 5.)
  //     return false;

  //   FldVector bdip;
  //   CalcDipole (xp, bdip);

  //   FldVector ep, ea, er; // parallel, azimuthal, radial E direction
  //   er.Set (xp);
  //   ep.Set (bdip);
  //   ea = ep % er;
  //   er = ea % ep;

  //   ep.Normalize ();
  //   ea.Normalize ();
  //   er.Normalize ();

  //   T amp = _ulfamp * Math::Exp (- (tht*tht + dis*dis));
  //   T arg = _ulfomega * BASE(_time).Time ();

  //   ea *= amp * Math::Sin (arg);
  //   efsrc = ea;

  //   return true;
  // }



  // void EcalcBC (const DomainIterator<D> &ite)
  // {
  //   PosVector xp = ite.GetPosition ();
  //   xp -= _cx;

  //   T xpnorm = xp.Norm ();
  //   static T radmax = _radius + _dx.Norm ();
  //   if (xpnorm < radmax)
  //   {
  //     /// Angle of rotation of Z-axis
  //     T phiz = atan2(xp[0], xp[1]);
  //     ZRotMatrix3<T> rotz (phiz);
  //     ReversibleTransform<T> trans (rotz, T(0));

  //     FldVector ef;

  //     ef = BASE(_E)(ite);
  //     ef = trans.Other2ThisRelative (ef);
  //     ef[0] = ef[0] * (xpnorm-_radius);
  //     ef[1] = Math::Abs (ef[1]);
  //     ef = trans.This2OtherRelative (ef);

  //     BASE(_E)(ite) = ef;
  //   }
  // }




  // void VthInitAdd (TSpecie *sp, ScaField &vthper, ScaField &vthpar)
  // {
  //   PosVector xp;
  //   DomainIterator<D> it;
  //   vthper.GetDomainIteratorAll (it, false);
  //   T vthpar0 = sp->Vthpar ();
  //   T vthper0 = sp->Vthper ();

  //   T spani = sp->Anisotropy ();
  //   SAT_ASSERT_MSG (Math::Abs (spani - 1.) < 0.0001, "Anisotropy must be 1");

  //   /// See chan94 for explanation
  //   T dn, p0, ms, vth;
  //   do
  //   {
  //     xp = it.GetPosition ();
  //     xp -= _cx;

  //     dn = CalcDn (sp, xp);
  //     ms = sp->Mass ();
  //     CalcPressure0 (sp, xp, p0);
  //     vth = Math::Sqrt (p0 / (dn*ms));

  //     vthpar(it) = vth;
  //     vthper(it) = vth;
  //   }
  //   while (it.Next());
  // }




  // /// Returns B0vacuum / Bvacuum
  // T CalcB0B (const PosVector &xp)
  // {
  //   const T radius = xp.Norm ();
  //   if (radius < 0.0001)
  //     return 0.;

  //   const T lambda = Math::ASin (xp[D-1]/radius);
  //   const T sinlam = Math::Sin (lambda);
  //   const T coslam = Math::Cos (lambda);
  //   const T sin2 = sinlam*sinlam;
  //   const T cos6 = coslam*coslam*coslam*coslam*coslam*coslam;

  //   return cos6 / Math::Sqrt (1. + 3. *sin2);
  // }
