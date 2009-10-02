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
HIParticleSensor<T>::HIParticleSensor ()
  : _firstwr(true) {}

template<class T>
void HIParticleSensor<T>::Initialize (TSpecie *spec, const char *id,
				      ConfigFile &cfg)
{
#ifdef HAVE_H5PART
  Sensor::Initialize (id, cfg);

  if (Enabled ())
  {
    _spec = spec;
    DBG_INFO ("  npcles : " << _npcle);
    DBG_INFO ("  wmin   : " << _wmin);
  }
#endif // HAVE_H5PART
}

template<class T>
void HIParticleSensor<T>::InitializeLocal (const ConfigEntry &cfg)
{
  cfg.GetValue ("npcle", _npcle);
  cfg.GetValue ("wmin", _wmin);
}

template<class T>
void HIParticleSensor<T>::SaveData (IOManager &iomng, const SimulTime &stime)
{
#ifdef HAVE_H5PART
  const TParticleArray &pcles = _spec->GetIons (0);

  float x[_npcle];
  float y[_npcle];
  float z[_npcle];
  float v[_npcle];

  int pid = 0, npcle = 0;
  while (npcle < _npcle && pid < pcles.GetSize ())
  {
    const TParticle &pcle = pcles.Get (pid++);
    const Vector<T,3> &xp = pcle.GetPosition ();

    if (pcle.GetWeight () < 0)
      continue;

    x[npcle] = xp[0];
    y[npcle] = xp[1];
    z[npcle] = xp[2];
    v[npcle] = pcle.GetVelocity().Norm ();
    ++npcle;
  }

  // reset the values, which we didn't use, to zero
  if (npcle < _npcle)
  {
    memset (&x[npcle], 0, sizeof(float)*(_npcle-npcle));
    memset (&y[npcle], 0, sizeof(float)*(_npcle-npcle));
    memset (&z[npcle], 0, sizeof(float)*(_npcle-npcle));
    memset (&v[npcle], 0, sizeof(float)*(_npcle-npcle));
  }

  String fname = iomng.GetFileName (GetTag ("Pci"));
  fname += ".h5";

  if (_firstwr)
  {
    _file= H5PartOpenFile (fname, H5PART_WRITE);
    _firstwr = false;
  }
  else
    _file= H5PartOpenFile (fname, H5PART_APPEND);

  H5PartSetNumParticles (_file, _npcle);
  H5PartSetStep (_file, stime.Iter ());

  H5PartWriteDataFloat32 (_file, "x", x);
  H5PartWriteDataFloat32 (_file, "y", y);
  H5PartWriteDataFloat32 (_file, "z", z);
  H5PartWriteDataFloat32 (_file, "v", v);

  H5PartCloseFile (_file);
#endif // HAVE_H5PART
}

template class HIParticleSensor<float>;
template class HIParticleSensor<double>;
