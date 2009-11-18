/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   distfnc.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "distfnc.h"

template <class T, int D>
void DistFncSensor<T,D>::Initialize (ConfigFile &cfg, const char *id,
				     TSpecieRefArray *sparr, TVecField *bfld)
{
  Sensor::Initialize (cfg, id);
  _species = sparr;
  _bfld = bfld;

  // local configuration
  if (Enabled ())
  {
    ConfigEntry &ent = cfg.GetEntry (GetEntryID ());
    _bins = 20;
    ent.GetValue ("bins", _bins, _bins);
    _bins += 2;
    ent.GetValue ("vmin", _vmin);
    ent.GetValue ("vmax", _vmax);
    SAT_ASSERT (_vmin < _vmax);
    ent.GetValue ("perpar", _perpar, true);
    DBG_INFO (" => bins = "<<_bins<<"; velocity = "<<_vmin<<" -> "<<_vmax);
  }
}

template <class T, int D>
void DistFncSensor<T,D>::SaveData (IOManager &iomng, const SimulTime &stime)
{
  Field<uint32_t, D+3> fld;
  Vector<int, D+3> dims;

  TSpecie *specie = _species->Get (0);
  const Mesh<D> &mesh = specie->GetMesh ();

  for (int i=0; i<D+3; ++i)
  {
    if (i<D)
      dims[i] = mesh.GetCells (i)-1;
    else
      dims[i] = _bins[i-D];
  }

  fld.Initialize (dims);
  fld = 0.;

  float vmin, vmax;
  Vector<int,D+3> pspos;
  for (int i=0; i<specie->GetSize (); ++i)
  {
    const TParticle &pcle = specie->Get (i);
    for (int j=0; j<D+3; ++j)
    {
      if (j<D)
      {
	pspos[j] = Math::Floor (pcle.pos[j]);
      }
      else
      {
	vmin = _vmin[j-D];
	vmax = _vmax[j-D];

	if (pcle.vel[j-D] < vmin)
	  pspos[j] = 0;
	else if (pcle.vel[j-D] > vmax)
	  pspos[j] = _bins[j-D] - 1;
	else
	{
	  float cast = float(_bins[j-D]-1) / (vmax-vmin);
	  pspos[j] = Math::Floor ((pcle.vel[j-D]-vmin)*cast);
	}
      }
    }

    fld (pspos) += 1;
  }

  iomng.Write (fld, stime, GetTag ());
}

/*******************/
/* Specialization: */
/*******************/

#define DISTFNCSENS_SPECIALIZE_DIM(type,dim) \
  template class DistFncSensor<type,dim>;

#define DISTFNCSENS_SPECIALIZE(type) \
  DISTFNCSENS_SPECIALIZE_DIM(type,1) \
  DISTFNCSENS_SPECIALIZE_DIM(type,2) \
  DISTFNCSENS_SPECIALIZE_DIM(type,3)

DISTFNCSENS_SPECIALIZE(float)
DISTFNCSENS_SPECIALIZE(double)
