/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   shock.h
 * @brief  Simulation of shock wave.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SHOCK_CAM_H__
#define __SAT_SHOCK_CAM_H__

#include "sat.h"

/**
 * @brief Simulation of shock wave.
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class ShockCAMCode : public CAMCode<ShockCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<ShockCAMCode<T,D>,T,D> TBase;
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
    T max = ((TBase*)this)->_pmax[0];
    bool isright = ((TBase*)this)->_layop.GetDecomp ().IsRightBnd (0);
    if (pcle.pos[0] > max && isright)
    {
      pcle.pos[0] = 2.*max - pcle.pos[0];
      pcle.vel[0] = -pcle.vel[0];
    }

    return false;
  }

  void DnInitAdd (TSpecie *sp, ScaField &dn)
  {
    _nc=0.; _ip=0.; _dx=0.;
    FldVector np=0., lx=0., xp=0.;
    for (int i=0; i<D; ++i)
    {
      _nc[i] = dn.Size(i)-3;
      np[i] = dn.GetLayout().GetDecomp().GetSize(i);
      _ip[i] = dn.GetLayout().GetDecomp().GetPosition(i);
      _dx[i] = dn.GetMesh().GetResol(i);
      lx[i] = _nc[i] * np[i] * _dx[i];
    }

    DomainIterator<D> it( dn.GetDomainAll() );
    do
    {
      for (int i=0; i<D; ++i)
        xp[i] = ( (T)(it.GetLoc()[i])- 1. + _ip[i]*_nc[i] ) * _dx[i];

      dn(it) = _dnmin + (_dnmax-_dnmin) *
        (Math::Tanh ((xp[0]-lx[0]*_rpos)/_thick)/2.+.5);
    }
    while (it.Next());
  }

  void MomBCAdd (ScaField &dn, VecField &blk)
  {
    Domain<D> dom;

    const int i=0;
    const Layout<D>& layout = ((TBase*)this)->_layop;
    if (layout.IsOpen (i) && layout.GetDecomp().IsLeftBnd (i))
    {
      dn.GetDomainAll (dom);
      dom[i] = Range (0, 1);
      dn.Set (dom, _dnmin);

      // blk.GetDomainAll (dom);
      // dom[i] = Range (0, 1);
      // blk.Set (dom, _v0);
    }

    if (layout.IsOpen (i) && layout.GetDecomp().IsRightBnd (i))
    {
      dn.GetDomainAll (dom);
      dom[i] = Range (dn.Size(i)-2, dn.Size(i)-1);
      dn.Set (dom, _dnmax);

      // blk.GetDomainAll (dom);
      // dom[i] = Range (blk.Size(i)-2, blk.Size(i)-1);
      // blk.Set (dom, _v0);
    }
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

  // T BmaskAdd (const DomainIterator<D> &itb)
  // {
  //   PosVector xp;
  //   for (int i=0; i<D; ++i)
  //     xp[i] = (T(itb.GetLoc()[i])+ _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

  //   T ld = 4.;
  //   T ee = (xp.Norm()-_radius)/ld;
  //   return (T)1. - Math::Exp (-ee*ee);
  // }

  // T EmaskAdd (const DomainIterator<D> &ite)
  // {
  //   PosVector xp;
  //   for (int i=0; i<D; ++i)
  //     xp[i] = (T(ite.GetLoc()[i]) - 0.5 + _ip[i]*_nc[i]) * _dx[i] - _cx[i];

  //   T ld = 10.;
  //   T ee = (xp.Norm()-_radius)/ld;
  //   return (T)1. - Math::Exp (-ee*ee*ee);
  // }

  // bool EcalcAdd (const DomainIterator<D> &ite)
  // {
  //   PosVector xp;
  //   for (int i=0; i<D; ++i)
  //     xp[i] = ( T(ite.GetLoc()[i]) - 0.5 + _ip[i]*_nc[i] )*_dx[i] - _cx[i];

  //   if (xp.Norm2() < _radius2)
  //     return true;

  //   return false;
  // }

  // bool BcalcAdd (const DomainIterator<D> &itb)
  // {
  //   PosVector xp;
  //   for (int i=0; i<D; ++i)
  //     xp[i] = ( T(itb.GetLoc()[i])+ _ip[i]*_nc[i] )*_dx[i] - _cx[i];

  //   if (xp.Norm2() < _radius2)
  //     return true;

  //   return false;
  // }

  // void BInitAdd (VecField &b)
  // {
  //   _nc=0.; _ip=0.; _cx=0.; _dx=0.;
  //   FldVector mv=0., np=0., lx=0., xp=0.;
  //   for (int i=0; i<D; ++i)
  //   {
  //     _nc[i] = b.Size(i)-1;
  //     np[i] = b.GetLayout().GetDecomp().GetSize(i);
  //     _ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
  //     _dx[i] = b.GetMesh().GetResol(i);
  //     lx[i] = _nc[i] * np[i] * _dx[i];
  //     _cx[i] = lx[i] * _rpos[i];
  //   }
  //   mv[D-1] = _amp;

  //   DomainIterator<D> it( b.GetDomainAll() );
  //   do
  //   {
  //     for (int i=0; i<D; ++i)
  //       xp[i] = ( (T)(it.GetLoc()[i])+ _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

  //     T r3 = xp.Norm() * xp.Norm2();
  //     xp.Normalize();
  //     b(it) += ((T)3.*(mv*xp) * xp - mv)/r3;
  //   }
  //   while (it.Next());
  // }

private:
  T _dnmin, _dnmax, _rpos, _thick;
  bool _shock;
  Vector<T,D> _nc, _ip, _dx;
};

#include "init.cpp"

#endif /* __SAT_SHOCK_CAM_H__ */
