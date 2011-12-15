/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   inst.h
 * @brief  Instability CAM simulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @revision{1.1}
 * @reventry{2010/01, @jparal}
 * @revmessg{Move functions into separate source files.}
 */

#ifndef __SAT_INST_CAM_H__
#define __SAT_INST_CAM_H__

#include "sat.h"

/**
 * @brief Instability CAM simulation class
 *
 * Initialization is now dimension independent
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initialization is now dimension independent.}
 * @revmessg{Print configuration of wave setup.}
 * @revision{1.1}
 * @reventry{2010/01, @jparal}
 * @revmessg{Allow initialization of various plasma waves.}
 */
template<class T, int D>
class InstabilityCAMCode : public CAMCode<InstabilityCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<InstabilityCAMCode<T,D>,T,D> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef Particle<T,D> TParticle;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;
  typedef typename TBase::PosVector PosVector;

  /// @brief Parse the configuration file arguments before CAM code does.
  /// @param cfg Root of configuration file.
  virtual void PreInitialize (const ConfigFile &cfg);

  /// @brief Initialize application after CAM code does.
  /// @param cfg Root of configuration file.
  virtual void PostInitialize (const ConfigFile &cfg);

  void BulkInitAdd (TSpecie *sp, VecField &U)
  {
    if (!_wave)
      return;

    Vector<int,D> nc, ip;
    for (int i=0; i<D; ++i)
    {
      nc[i] = U.Size (i)-1;
      ip[i] = U.GetLayout ().GetDecomp ().GetPosition (i);
    }

    DomainIterator<D> it;
    U.GetDomainIteratorAll (it, false);
    do
    {
      T pos = T(0);
      for (int i=0; i<D; ++i)
        pos += (T)(it.GetLoc()[i] + ip[i]*nc[i]) * _k[i];

      // T kx = _k * it.GetPosition ();
      U(it)[1] += _amp * Math::Cos (pos);
      U(it)[2] += _amp * Math::Sin (pos);
    }
    while (it.Next ());
  }

  void BInitAdd (VecField &b)
  {
    if (!_wave)
      return;

    Vector<int,D> nc, ip;
    for (int i=0; i<D; ++i)
    {
      nc[i] = b.Size (i)-1;
      ip[i] = b.GetLayout ().GetDecomp ().GetPosition (i);
    }

    DomainIterator<D> it (b.GetDomainAll ());

    T pos;
    do
    {
      pos = (T)0.;
      for (int i=0; i<D; ++i)
        pos += (T)(it.GetLoc()[i] + ip[i]*nc[i]) * _k[i];

      b(it.GetLoc())[1] -= _amp * Math::Cos (pos);
      b(it.GetLoc())[2] -= _amp * Math::Sin (pos);
    }
    while (it.Next ());
  }

  bool VthInitAdd (TSpecie *sp, ScaField &vthper, ScaField &vthpar)
  {
    if (!_anisotropy)
      return false;

    PosVector xp;
    DomainIterator<D> it;
    vthper.GetDomainIteratorAll (it, false);
    T spani = sp->Anisotropy ();
    do
    {
      xp = it.GetPosition ();
      xp -= _acx;

      T pos = xp[0];
      T kill = 1.; //0.5 * (-Math::Tanh ((xp.Norm () - dist)/_radius) + 1.);
      T ani = (_aamp-spani)*kill*Math::Exp (-pos*pos / (2.*_awidth)) + spani;
      T rvth = Math::Sqrt (ani);
      vthper(it) = rvth * vthpar(it);
    }
    while (it.Next());

    return true;
  }

private:
  bool _anisotropy;     ///< enable anisotropy profile initialization
  T _aamp;              ///< Amplitude of anisotropy
  T _awidth;            ///< Width of anisotropy profile
  T _arx;               ///< Relative position of the center of anisotropy
  Vector<T,D> _acx;     ///< Center of anisotropy (i.e arx * Lx)

  bool _wave;           ///< enable wave initialization
  String _mode;
  T _angle;             ///< angle (k,x) in XY plane
  T _amp;               ///< amplitude of wave
  Vector<int,D> _npex;  ///< number of periods in X
  Vector<T,D> _k;       ///< k vector of the wave
};

#include "init.cpp"

#endif /* __SAT_INST_CAM_H__ */
