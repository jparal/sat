/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   khbox.h
 * @brief  Simulation of Kelvin-Helmholtz instability in 2D box.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2012/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_KHBOX_CAM_H__
#define __SAT_KHBOX_CAM_H__

#define BASE(var) ((TBase*)this)->var

#include "sat.h"

/**
 * @brief Simulation of Kelvin-Helmholtz instability in 2D box.
 *
 * @revision{1.0}
 * @reventry{2012/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class KHBoxCAMCode : public CAMCode<KHBoxCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<KHBoxCAMCode<T,D>,T,D> TBase;
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

  void BInitAdd (VecField &b)
  {
    _nc=0.; _ip=0.; _cx=0.; _dx=0.; _dxi=0.;

    for (int i=0; i<D; ++i)
    {
      _nc[i] = b.Size(i)-1;
      _np[i] = b.GetLayout().GetDecomp().GetSize(i);
      _ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
      _dx[i] = b.GetMesh().GetResol(i);
      _dxi[i] = 1./_dx[i];
      _lx[i] = _nc[i] * _np[i] * _dx[i];
      _cx[i] = _lx[i] * T(0.5);
    }

    DomainIterator<D> it;
    b.GetDomainIteratorAll (it, false);
    do
    {
      BcalcBC (b,it);
    }
    while (it.Next());

  }

  // void BcalcBC (VecField &Ba, const DomainIterator<D> &it)
  // {
  //   Ba(it) = Bcalc(it.GetPosition());
  // }

  // FldVector Bcalc (const PosVector &xp)
  // {
  //   FldVector b0 (0.);
  //   b0[2] = 0.1 + (Math::Tanh(+(xp[1]-_cx[1])/_ldjump)/2.+0.5);
  //   return b0;
  // }

  void BulkInitAdd (TSpecie *sp, VecField &u)
  {
    DomainIterator<D> it;
    u.GetDomainIteratorAll (it, false);
    SetBulkInit (u, it);
  }

  // void DnInitAdd (TSpecie *sp, ScaField &dn)
  // {
  //   DomainIterator<D> it;
  //   dn.GetDomainIteratorAll (it, false);
  //   SetDnInit (dn, it);
  // }

  void SetBulkInit (VecField &u, DomainIterator<D> &it)
  {
    PosVector xp;
    do
    {
      xp = it.GetPosition ();
      u(it) = BulkBCAdd (NULL, xp);
    }
    while (it.Next());
  }

  // void SetDnInit (ScaField &dn, DomainIterator<D> &it)
  // {
  //   PosVector xp;
  //   do
  //   {
  //     xp = it.GetPosition ();
  //     dn(it) = 1. + (_dnjump-1.) * (Math::Tanh(-(xp[1]-_cx[1])/_ldjump)/2.+0.5);
  //   }
  //   while (it.Next());
  // }


  VelVector BulkBCAdd (TSpecie *sp, const PosVector &xp)
  {
    if (sp == NULL)
      sp = BASE(_specie).Get (0);

    T nperiod = 3.;
    T delta = 0.18 / (nperiod*M_2PI/_lx[0] / 6.8);
    T kxr =   0.3  * (nperiod*M_2PI/_lx[0] / 6.8);
    T kx =    6.8  * (nperiod*M_2PI/_lx[0] / 6.8);
    T eps = 1.;
    T v0 = 5.6659/280.;

    T delta2 = delta*delta;
    T x = xp[0];
    T y = xp[1] - _cx[1];


    // = sp->InitalVel ();
    VelVector u0;
    T expy = Math::Exp (-y*y/delta2);
    u0[0] = -v0 * expy * 2.*y / (delta2*kxr);
    u0[1] =  v0 * expy * (eps*Math::Cos(kx*x));
    u0[2] = 0.;

    return u0;
  }

  // T DnBCAdd (TSpecie *sp, const PosVector &pos)
  // {
  //   T dn = 1. + (_dnjump-1.) * (Math::Tanh(-(pos[1]-_cx[1])/_ldjump)/2.+0.5);
  //   return dn;
  // }

  // FldVector EcalcBCAdd (const DomainIterator<D> &it)
  // {
  //   PosVector xp = it.GetPosition ();
  //   FldVector e = - BulkBCAdd (NULL, xp) % Bcalc(xp);
  //   return e;
  // }

  // void MomBCAdd (ScaField &dn, VecField &blk)
  // {
  //   Domain<D> dom;
  //   DomainIterator<D> blkit, dnit;
  //   dn.GetDomainIteratorAll (dnit, false);
  //   blk.GetDomainIteratorAll (blkit, false);

  //   for (int i=0; i<D; ++i)
  //   {
  //     if (BASE(_layop).IsOpen (i) && BASE(_layop).GetDecomp().IsLeftBnd (i))
  //     {
  //       dn.GetDomainAll (dom);
  //       dom[i] = Range (0, 1);
  // 	dnit.SetDomain (dom);
  // 	SetDnInit (dn, dnit);

  //       blk.GetDomainAll (dom);
  //       dom[i] = Range (0, 1);
  // 	blkit.SetDomain (dom);
  // 	SetBulkInit (blk, blkit);
  //     }

  //     if (BASE(_layop).IsOpen (i) && BASE(_layop).GetDecomp().IsRightBnd (i))
  //     {
  // 	dn.GetDomainAll (dom);
  // 	dom[i] = Range (dn.Size(i)-2, dn.Size(i)-1);
  // 	dnit.SetDomain (dom);
  // 	SetDnInit (dn, dnit);

  // 	blk.GetDomainAll (dom);
  // 	dom[i] = Range (blk.Size(i)-2, blk.Size(i)-1);
  // 	blkit.SetDomain (dom);
  // 	SetBulkInit (blk, blkit);
  //     }
  //   }
  // }

private:
  T _dnjump;
  T _ldjump;

  Vector<T,D> _np, _nc, _ip, _cx, _lx, _dx, _dxi;
};

#include "init.cpp"

#endif /* __SAT_KHBOX_CAM_H__ */
