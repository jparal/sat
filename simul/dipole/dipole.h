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

    if (xp.Norm2() < _radius2)
    {
      sp->Exec (id, PCLE_CMD_REMOVE);
      return true;
    }

    return false;
  }

  void EfieldAdd ()
  {
    Domain<D> dom;
    ((TBase*)this)->_E.GetDomain (dom);  DomainIterator<D> ite (dom);
    PosVector xp;
    do
    {
      for (int i=0; i<D; ++i)
	xp[i] = ( T(ite.GetLoc()[i]) - 0.5 + _ip[i]*_nc[i] )*_dx[i] - _cx[i];

      if (xp.Norm2() < _radius2)
      	((TBase*)this)->_E(ite) = 0.;
    }
    while (ite.Next());
  }

  bool EcalcAdd (const DomainIterator<D> &ite)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = ( T(ite.GetLoc()[i]) - 0.5 + _ip[i]*_nc[i] )*_dx[i] - _cx[i];

    if (xp.Norm2() < _radius2)
      return true;

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

    return false;
  }

  bool BcalcAdd (const DomainIterator<D> &itb)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = ( T(itb.GetLoc()[i])+ _ip[i]*_nc[i] )*_dx[i] - _cx[i];

    if (xp.Norm2() < _radius2)
      return true;

    return false;
  }

  void BInitAdd (VecField &b)
  {
    _nc=0.; _ip=0.; _cx=0.; _dx=0.;
    FldVector mv=0., np=0., lx=0., xp=0.;
    for (int i=0; i<D; ++i)
    {
      _nc[i] = b.Size(i)-1;
      np[i] = b.GetLayout().GetDecomp().GetSize(i);
      _ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
      _dx[i] = b.GetMesh().GetResol(i);
      lx[i] = _nc[i] * np[i] * _dx[i];
      _cx[i] = lx[i] * _rpos[i];
    }
    mv[D-1] = _amp;

    DomainIterator<D> it( b.GetDomainAll() );
    do
    {
      for (int i=0; i<D; ++i)
        xp[i] = ( (T)(it.GetLoc()[i])+ _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

      T r3 = xp.Norm() * xp.Norm2();
      r3 = r3 > 0.0001 ? r3 : 0.0001;
      xp.Normalize();
      b(it) += ((T)3.*(mv*xp) * xp - mv)/r3;
    }
    while (it.Next());
  }

  // T ResistAdd (const PosVector &pos) const
  // {
  //   PosVector cp;
  //   for (int i=0; i<D; ++i)
  //     cp[i] = pos[i]*_dx[i] - _cx[i];

  //   /// Exponential resistivity
  //   // T ld = 4.0;
  //   // T ee = (cp.Norm()-_radius)/ld;
  //   // return Math::Exp (-ee * ee);

  //   /// Tangential resistivity
  //   T ld = 4.0;
  //   T am = 0.8;
  //   T rm = 0.8;
  //   T ee = cp.Norm()-_radius;
  //   return am*(Math::ATan ((-ee+ld)/rm)/M_PI+0.5);
  // }

  T BmaskAdd (const DomainIterator<D> &itb)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = (T(itb.GetLoc()[i])+ _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

    T ld = 2.;
    T ee = (xp.Norm()-_radius)/ld;
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

    T ld = 2.;
    T ee = (xp.Norm()-_radius)/ld;
    if (ee > 5.)
      return (T)1.;
    else
      return (T)1. - Math::Exp (-ee*ee);
  }

private:
  bool _dipole;
  T _amp, _radius, _radius2;
  Vector<T,D> _rpos, _nc, _ip, _cx, _dx;
};

#include "init.cpp"

#endif /* __SAT_DIPOLE_CAM_H__ */
