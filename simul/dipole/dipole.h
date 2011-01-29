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
    if (dist2 < _radius2*(0.99*0.99))
    {
      sp->Exec (id, PCLE_CMD_REMOVE);
      return true;
    }

    /// Reflect particle from the surface with random velocity smaller then the
    /// original one
    if (dist2 < _radius2*(1.01*1.01))
    {
      VelVector vpar, vper, vnor = T(0);
      for (int i=0; i<D; ++i)
        vnor[i] = xp[i];

      vnor.Normalize ();
      vpar = pcle.vel >> vnor;
      vper = pcle.vel - vpar;
      vnor *= vpar.Norm () * _rand.Get ();
      pcle.vel = vnor + vper;
    }

    return false;
  }

  void EfieldAdd ()
  {
    DomainIterator<D> ite;
    ((TBase*)this)->_E.GetDomainIterator (ite, false);
    PosVector xp;
    do
    {
      xp = ite.GetPosition ();
      xp -= _cx;

      if (xp.Norm2() < _radius2)
        ((TBase*)this)->_E(ite) = 0.;
    }
    while (ite.Next());
  }

  bool EcalcAdd (const DomainIterator<D> &ite)
  {
    PosVector xp = ite.GetPosition ();
    xp -= _cx;

    // Don't update electric field inside of the planet
    if (xp.Norm2() < _radius2)
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

  bool EcalcSrc (const DomainIterator<D> &ite, FldVector &efsrc)
  {
    /// Apply ULF source in equator plane
    if (!_ulfenable)
      return false;

    PosVector xp = ite.GetPosition ();
    xp -= _cx;

    FldVector bdip;
    CalcDipole (xp, bdip);

    T ee = (Math::Abs (xp[D-1]))/_ulfwidth;
    T dd = (Math::Abs (xp[0]) - _ulfdist)/_ulfwidth;
    if (ee + dd > 5.)
      return false;

    FldVector epar, eper1, eper2;

    // epar.Set (xp);
    // eper1 = epar % bdip;
    // //    eper2 = eper1 % bdip;
    // eper1.Normalize ();
    // //    eper2.Normalize ();

    eper1.Set (xp);
    bdip.Normalize ();
    eper1 -= eper1 >> bdip;
    eper1.Normalize ();
    eper1 = eper1 % bdip;

    T arg = _ulfomega * ((TBase*)this)->_time.Time ();
    T amp = _ulfamp * Math::Exp (-(ee*ee + dd*dd));
    eper1 *= amp * Math::Sin (arg);
    //    eper2 *= amp * Math::Cos (arg);
    efsrc = eper1; // + eper2;

    return true;
  }

  void BInitAdd (VecField &b)
  {
    _nc=0.; _ip=0.; _cx=0.; _dx=0.;
    FldVector bdip, np=0., lx=0.;
    PosVector xp;
    for (int i=0; i<D; ++i)
    {
      _nc[i] = b.Size(i)-1;
      np[i] = b.GetLayout().GetDecomp().GetSize(i);
      _ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
      _dx[i] = b.GetMesh().GetResol(i);
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
    PosVector cp = iter.GetPosition ();
    cp -= _cx;

    /// Tangential resistivity
    T ld = 4.0, am = 0.8, rm = 0.8, ee = cp.Norm()-_radius;
    return am*(Math::ATan ((-ee+ld)/rm)/M_PI+0.5);
  }

  T BmaskAdd (const DomainIterator<D> &itb)
  {
    PosVector xp = itb.GetPosition ();
    xp -= _cx;

    T ld = 2., ee = (xp.Norm()-_radius)/ld;
    if (ee > 5.)
      return (T)1.;
    else
      return (T)1. - Math::Exp (-ee*ee);
  }

  T EmaskAdd (const DomainIterator<D> &ite)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = (T(ite.GetLoc()[i]) - 0.5 + _ip[i]*_nc[i]) * _dx[i] - _cx[i];

    T ld = 2., ee = (xp.Norm()-_radius)/ld;
    if (ee > 5.)
      return (T)1.;
    else
      return (T)1. - Math::Exp (-ee*ee);
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
    mv[D-1] = _amp;

    T r3 = xp.Norm() * xp.Norm2();
    xp.Normalize();

    if (r3 > r3min)
      bdip = ((T)3.*(mv*xp) * xp - mv)/r3;
    else
      bdip = ((T)3.*(mv*xp) * xp - mv)/r3min;
  }

private:
  RandomGen<T> _rand;
  MaxwellRandGen<T> _maxw;

  // ULF source
  bool _ulfenable;
  T _ulfamp, _ulfomega, _ulfdist, _ulfwidth;

  // Planet position
  bool _dipole;
  T _amp, _radius, _radius2;
  Vector<T,D> _rpos, _nc, _ip, _cx, _dx;
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
