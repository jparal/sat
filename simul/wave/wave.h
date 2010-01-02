/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wave.h
 * @brief  Wave CAM simulation class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @revision{1.1}
 * @reventry{2009/12, @jparal}
 * @revmessg{Rename from alfven to wave}
 */

#ifndef __SAT_WAVE_CAM_H__
#define __SAT_WAVE_CAM_H__

#include "sat.h"

/**
 * @brief Wave CAM simulation class
 *
 * Initialization is now dimension independent
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/03, @jparal}
 * @revmessg{initialization is now dimension independent}
 * @revmessg{print configuration of wave setup}
 */
template<class T, int D>
class WaveCAMCode : public CAMCode<WaveCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<WaveCAMCode<T,D>,T,D> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef Particle<T,D> TParticle;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;

  virtual void PreInitialize (const ConfigFile &cfg)
  {
    cfg.GetValue ("wave.nperiod", _npex);
    cfg.GetValue ("wave.amp", _amp);
    cfg.GetValue ("wave.vphase", _grpvel, 1.0);
  }

  virtual void PostInitialize (const ConfigFile &cfg)
  {
    Vector<T,D> l, k;
    VecField &U = this->_U;

    for (int i=0; i<D; ++i)
    {
      int nc = U.Size (i)-1;
      int gh = U.GetLayout ().GetGhost (i);
      int np = U.GetLayout ().GetDecomp ().GetSize (i);
      T dx = U.GetMesh ().GetResol (i);
      _k[i] = (M_2PI * (T)_npex[i]) / ((T)((nc - 2*gh) * np));

      k[i] = _k[i] / dx;
      l[i] = M_2PI/k[i];
    }

    DBG_INFO ("Wave simulation:");
    DBG_INFO ("  nperiod           : "<<_npex);
    DBG_INFO ("  amp       [B_0]   : "<<_amp);
    DBG_INFO ("  vphase    [v_A]   : "<<_grpvel);
    DBG_INFO ("  k         [w_p/c] : "<< k);
    DBG_INFO ("  lambda    [c/w_p] : "<< l);
  }

  void BulkInitAdd (TSpecie *sp, VecField &U)
  {
    Vector<int,D> nc, ip;
    for (int i=0; i<D; ++i)
    {
      nc[i] = U.Size (i)-1;
      ip[i] = U.GetLayout ().GetDecomp ().GetPosition (i);
    }

    Domain<D> dom;
    U.GetDomainAll (dom);
    DomainIterator<D> it (dom);

    T pos;
    while (it.HasNext ())
    {
      pos = (T)0.;
      for (int i=0; i<D; ++i)
	pos += (T)(it.GetLoc()[i] + ip[i]*nc[i]) * _k[i];

      U(it.GetLoc())[1] = _amp * _grpvel * Math::Cos (pos);
      U(it.GetLoc())[2] = _amp * _grpvel * Math::Sin (pos);

      it.Next ();
    }
  }

  void BInitAdd (VecField &b)
  {
    Vector<int,D> nc, ip;
    for (int i=0; i<D; ++i)
    {
      nc[i] = b.Size (i)-1;
      ip[i] = b.GetLayout ().GetDecomp ().GetPosition (i);
    }

    Domain<D> dom;
    b.GetDomainAll (dom);
    DomainIterator<D> it (dom);

    T pos;
    while (it.HasNext ())
    {
      pos = (T)0.;
      for (int i=0; i<D; ++i)
	pos += (T)(it.GetLoc()[i] + ip[i]*nc[i]) * _k[i];

      b(it.GetLoc())[1] -= _amp * Math::Cos (pos);
      b(it.GetLoc())[2] -= _amp * Math::Sin (pos);

      it.Next ();
    }
  }

private:
  Vector<int,D> _npex;          /**< number of periods in X */
  T _amp;			/**< amplitude */
  T _grpvel;			/**< group velocity */
  Vector<T,D> _k;
};

#endif /* __SAT_WAVE_CAM_H__ */
