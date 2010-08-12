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
      xp[i] = ( pcle.pos[i] + _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

    if (xp.Norm2() < _radius2)
    {
      sp->Exec (id, PCLE_CMD_REMOVE);
      return true;
    }
    else
    {
      return false;
    }
  }

  bool EcalcAdd (const DomainIterator<D> &iter)
  {
    return BcalcAdd (iter);
  }

  bool BcalcAdd (const DomainIterator<D> &iter)
  {
    PosVector xp;
    for (int i=0; i<D; ++i)
      xp[i] = ( (T)(iter.GetLoc()[i])+ _ip[i]*_nc[i] ) * _dx[i] - _cx[i];

    if (xp.Norm2() < _radius2)
      return true;
    else
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
      xp.Normalize();
      b(it) += ((T)3.*(mv*xp) * xp - mv)/r3;
    }
    while (it.Next());
  }

  void EfieldAdd()
  {
    // Set Et = 0 on the planet's surface
    
  }

private:
  bool _dipole;
  T _amp;
  T _radius2;
  Vector<T,D> _rpos;
  FldVector _nc, _ip, _cx, _dx;
};

#include "init.cpp"

#endif /* __SAT_DIPOLE_CAM_H__ */
