/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   herm.h
 * @brief  Simulation of magnetic herm in solar wind.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_HERM_CAM_H__
#define __SAT_HERM_CAM_H__

#define BASE(var) ((TBase*)this)->var

#include "sat.h"

/**
 * @brief Simulation of magnetic herm in solar wind.
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class HermCAMCode : public CAMCode<HermCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<HermCAMCode<T,D>,T,D> TBase;
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
    FldVector bdip, np=0., lx=0.;
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
      b(it) += bdip;
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

  void BulkInitAdd (TSpecie *sp, VecField &u)
  {
    PosVector xp;
    DomainIterator<D> it;
    u.GetDomainIteratorAll (it, false);

    /// See [Shue et al. 1997] for r0 and alpha explanation
    const T r0 = _radius * 2.;
    const T alpha = 0.6;
    const T rm = 0.5 *_radius;
    const FldVector u0 = BASE(_v0);

    do
    {
      xp = it.GetPosition ();
      xp -= _cx;
      T tht = Math::ATan2 (xp[1], -xp[0]);
      T dist = r0 * Math::Pow (T(2)/ (T(1)+Math::Cos(tht)), alpha);
      u(it) = u0;
      u(it) *= Math::ATan ((xp.Norm()-dist)/rm)/M_PI+0.5;
    }
    while (it.Next());

    // PosVector xp;
    // DomainIterator<D> it;
    // u.GetDomainIteratorAll (it, false);

    // const FldVector u0 = BASE(_v0);
    // const T ld = 0.5*(_cx[0]-_radius), rm = 2.*_radius;

    // do
    // {
    //   xp = it.GetPosition ();
    //   u(it) = u0;
    //   u(it) *= Math::ATan ((-xp[0]+ld)/rm)/M_PI+0.5;
    // }
    // while (it.Next());
  }

  void DnInitAdd (TSpecie *sp, ScaField &dn)
  {
    if (sp->GetName () != "ionosphere")
      return;

    PosVector xp;
    DomainIterator<D> it;
    dn.GetDomainIteratorAll (it, false);

    do
    {
      xp = it.GetPosition ();
      xp -= _cx;

      if (xp.Norm2 () < _radius2)
        dn(it) = 0.;

      /// Tangential profile of ionospheric particles
      T ld = 3. * _radius;
      T rm = _radius / 2.;
      T am = .1;
      T ee = xp.Norm()-_radius;

      dn(it) = am*(Math::ATan ((-ee+ld)/rm)/M_PI+0.5);
    }
    while (it.Next());
  }

  void CalcDipole (const PosVector &relpos, FldVector &bdip)
  {
    FldVector xp = 0., mv = 0.;
    for (int i=0; i<D; ++i) xp[i] = relpos[i];
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

private:
  RandomGen<T> _rand;
  MaxwellRandGen<T> _maxwplnorm;

  // Planet configuration
  bool _dipole;
  T _plbcleni;
  T _vthplnorm;
  T _amp, _radius, _radius2;
  Vector<T,D> _rpos, _nc, _ip, _cx, _dx, _dxi;
};

#include "init.cpp"

#endif /* __SAT_HERM_CAM_H__ */


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
//       if (pcle.pos[i] <= BASE(_pmin)[i] ||
//           BASE(_pmax)[i] <= pcle.pos[i])
//         repeat = true;
//     }
//   }
//   while (repeat);

//   xp.Normalize (Math::Abs (T(2.)+_maxw.Get ()));
//   pcle.vel[0] = xp[0];
//   pcle.vel[1] = xp[1];
//   pcle.vel[2] = 0.;
// }

// void VthInitAdd (TSpecie *sp, ScaField &vthper, ScaField &vthpar)
// {
//   PosVector xp;
//   DomainIterator<D> it;
//   vthper.GetDomainIteratorAll (it, false);
//   T spani = sp->Anisotropy ();
//   do
//   {
//     xp = it.GetPosition ();
//     xp -= _cx;

//     T width = _radius / 3.;
//     T ampl = 2.;
//     T dist = _radius * 3.;

//     T pos = xp[D-1];
//     T kill = 0.5 * (-Math::Tanh ((xp.Norm () - dist)/_radius) + 1.);
//     T ani = (ampl-spani)*kill*Math::Exp (-pos*pos / (2.*width)) + spani;
//     T rvth = Math::Sqrt (ani);
//     vthper(it) = ani * vthpar(it);
//   }
//   while (it.Next());
// }
