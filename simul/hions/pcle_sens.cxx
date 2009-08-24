/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   spec_sens.cxx
 * @brief  Specie sensor.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "pcle_sens.h"

template<class T>
HIParticleSensor<T>::~HIParticleSensor ()
{
#ifdef HAVE_H5PART
  H5PartCloseFile(_file);
#endif
}

template<class T>
void HIParticleSensor<T>::Initialize (TSpecie *spec, const char *id,
				      ConfigFile &cfg)
{
#ifdef HAVE_H5PART
  Sensor::Initialize (id, cfg);

  if (Enabled ())
  {
    _spec = spec;
    DBG_INFO ("  npcles : "<<_npcle);

    _file= H5PartOpenFile ("pokus.h5part", H5PART_WRITE);
    // sets number of particles in simulation we want to write
    H5PartSetNumParticles (_file, _npcle);
    //H5PartCloseFile(_file);
  }
#endif // HAVE_H5PART
}

template<class T>
void HIParticleSensor<T>::InitializeLocal (const ConfigEntry &cfg)
{
  cfg.GetValue ("npcle", _npcle);
}

template<class T>
void HIParticleSensor<T>::SaveData (IOManager &iomng, const SimulTime &stime)
{
#ifdef HAVE_H5PART
  const TParticleArray &pcles = _spec->GetIons (0);
  if (_npcle > pcles.GetSize ()) return;

  // _file= H5PartOpenFile("pokus.h5part",H5PART_APPEND);
  //  H5PartSetNumParticles(_file,_npcle);
  H5PartSetStep(_file,stime.Iter ());

  double *x = new double[_npcle];
  double *y = new double[_npcle];
  double *z = new double[_npcle];
  double *v = new double[_npcle];
  double *w = new double[_npcle];
  h5part_int64_t *id = new h5part_int64_t[_npcle];

  for (int i=0; i<_npcle; ++i)
  {
    const TParticle &pcle = pcles.Get (i);
    const Vector<T,3> &xp = pcle.GetPosition ();
    x[i] = xp[0];
    y[i] = xp[1];
    z[i] = xp[2];
    w[i] = pcle.GetWeight ();
    v[i] = pcle.GetVelocity().Norm ();
    id[i] = i;
  }

  H5PartWriteDataFloat64 (_file,"x",x);
  H5PartWriteDataFloat64 (_file,"y",y);
  H5PartWriteDataFloat64 (_file,"z",z);
  H5PartWriteDataFloat64 (_file,"w",w);
  H5PartWriteDataFloat64 (_file,"v",v);
  H5PartWriteDataInt64 (_file,"id",id);

  if (x) free (x);
  if (y) free (y);
  if (z) free (z);
  if (v) free (v);
  if (w) free (w);
  if (id) free (id);

  //  H5PartCloseFile(_file);
#endif // HAVE_H5PART
}

template class HIParticleSensor<float>;
template class HIParticleSensor<double>;
