/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   emitter.cxx
 * @brief  Particle emitter base class
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "emitter.h"
#include "satpint.h"

template<class T>
SphereEmitter<T>::SphereEmitter ()
  : _enabled(false)
{}

template<class T>
SphereEmitter<T>::~SphereEmitter ()
{}

template<class T>
void SphereEmitter<T>::Update (T dt, TParticleArray &ions,
			       TParticleArray &neut)
{
  _rmsrc += _src;
  EmitPcles (ions, neut);
}

template<class T>
void SphereEmitter<T>::EmitPcles (TParticleArray &ions, TParticleArray &neut)
{
  T conphi = M_2PI / (T)(_rmsrc.GetSize (0));
  T contht = M_PI  / (T)(_rmsrc.GetSize (1));

  Vector<T,3> sphl;
  // specify third coordinate (always constant)
  sphl[2] = (T)1.01 * _radius;

  for (int i=0; i<_rmsrc.GetSize (0); ++i)
    for (int j=0; j<_rmsrc.GetSize (1); ++j)
    {
      Vector<T,3> cart, axis, pos, vel;
      HIParticle<T> pcle;
      T vphi, vtht, vabs;

      while (_rmsrc(i,j) > 1.)
      {
	// update flux the generated position
	_rmsrc(i,j) -= 1.;

	sphl[0] = ((T)i + _unirng.Get ()) * conphi;
	sphl[1] = ((T)j + _unirng.Get ()) * contht;

	vphi = _unirng.Get () * M_2PI;
	vtht = _vthtrng.Get ();
	vabs = GenVelocity (sphl, vtht);

	// get global particle position
	Sph2CartGlobal (sphl, pos);
	// gen normal to the surface in local Cartesian coordinates
	Sph2CartLocal (sphl, axis);
	// get initial velocity  in local Cartesian coordinates
	sphl[1] += vtht; // update theta angle
	Sph2CartLocal (sphl, vel);

	// and rotate initial velocity vector by random form [0,2Pi]
	Quaternion<T> q (axis, vphi);
	vel = q.Rotate (vel);
	vel.Normalize ();
	vel *= vabs;

	pcle.SetPosition (pos);
	pcle.SetVelocity (vel);
	pcle.SetWeight (1.);

	if (_unirng.Get () < _ionsratio)
	  ions.Push (pcle);
	else
	  neut.Push (pcle);
      }
    }
}

template<class T>
void SphereEmitter<T>::Initialize (ConfigEntry &cfg, String tag,
				   const SIHybridUnitsConvert<T> &si2hyb,
				   const Vector<T,3> &pos, T radius)
{
  _tag = tag;
  _pos = pos;
  _si2hyb = si2hyb;
  _radius = radius;

  if (cfg.Exists (tag))
  {
    DBG_INFO ("emitter ("<<tag<<"): Enabled");
    Vector<int,2> npatch;
    cfg.GetValue ("npatch", npatch);
    cfg.GetValue ("npcles", _npcles);
    cfg.GetValue ("ionsratio", _ionsratio);

    SAT_ASSERT (0. < _ionsratio && _ionsratio < 100.);

    _enabled = true;
    _src.Initialize (npatch);

    ConfigEntry &entry = cfg[tag];
    InitializeLocal (entry, _si2hyb, _src);

    // scale the map
    _src *= _npcles / _src.Sum ();
    _rmsrc.Initialize (_src);
    _rmsrc = 0.;

    DBG_INFO ("  maximal value of map:       "<<_src.Max ());
    DBG_INFO ("  particles per time step:    "<<_src.Sum ());
    DBG_INFO ("  ions/neutral ratio [%]:     "<<_ionsratio);
    _ionsratio /= (T)100.;
  }
  else
  {
    DBG_INFO ("emitter ("<<tag<<"): Disabled");
  }
}

template<class T>
void SphereEmitter<T>::Sph2CartLocal (const Vector<T,3> &sphl,
				      Vector<T,3> &cart) const
{
  T cosphi = Math::Cos (sphl[0]);
  T sinphi = Math::Sin (sphl[0]);
  T costht = Math::Cos (sphl[1]);
  T sintht = Math::Sin (sphl[1]);
  T radius = sphl[2];

  cart[0] = radius * cosphi * sintht;
  cart[1] = radius * sinphi * sintht;
  cart[2] = radius * costht;
}

template<class T>
void SphereEmitter<T>::Sph2CartGlobal (const Vector<T,3> &sphl,
				       Vector<T,3> &cart) const
{
  Sph2CartLocal (sphl, cart);
  cart += _pos;
}

template class SphereEmitter<float>;
template class SphereEmitter<double>;
