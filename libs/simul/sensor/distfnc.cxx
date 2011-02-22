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

  // local configuration
  if (!Enabled ())
    return;

  _species = sparr;
  _bfld = bfld;
  _nchi = bfld->GetSize () - 1;
  Vector<int,D> iproc;
  for (int i=0; i<D; ++i)
    iproc[i] = bfld->GetLayout().GetDecomp().GetPosition (i);

  _nclo = _nchi;
  _nclo *= iproc;
  _nchi += _nclo - 1;

  ConfigEntry &ent = cfg.GetEntry (GetEntryID ());
  _bins = 20;
  ent.GetValue ("bins", _bins, _bins);
  ent.GetValue ("vmin", _vmin);
  ent.GetValue ("vmax", _vmax);
  ent.GetValue ("perpar", _perpar, true);

  SAT_ASSERT (_vmin < _vmax);

  DBG_INFO("  bins   : "<<_bins);
  DBG_INFO("  vmin   : "<<_vmin);
  DBG_INFO("  vmax   : "<<_vmax);

  if (_perpar)
  {
    Vector<T,2> vmin2, vmax2;
    Vector<int,2> bins2;
    for (int i=0; i<2; ++i)
    {
      vmin2[i] = _vmin[i];
      vmax2[i] = _vmax[i];
      bins2[i] = _bins[i];
    }
    _df2d.Initialize (bins2, vmin2, vmax2);
  }
  else
    _df3d.Initialize (_bins, _vmin, _vmax);

  Vector<int,D> pos;
  ConfigEntry &list = ent["list"];
  for (int i=0; i<list.GetLength (); ++i)
  {
    list.GetValue (i, pos);

    bool enable = true;
    for (int id=0; id<D; ++id)
      if (pos[id] < _nclo[id] || _nchi[id] < pos[id])
	enable = false;

    if (!enable)
      continue;

    // convert into local coordinates
    pos -= _nclo;

    if (_perpar)
      _df2d.AddDF (pos, _nclo);
    else
      _df3d.AddDF (pos, _nclo);
  }
}

template <class T, int D>
void DistFncSensor<T,D>::SaveData (IOManager &iomng, const SimulTime &stime)
{

  for (int sp=0; sp<_species->GetSize (); ++sp)
  {
    TSpecie *specie = _species->Get (sp);

    for (int pc=0; pc<specie->GetSize (); ++pc)
    {
      const TParticle &pcle = specie->Get (pc);

      if (_perpar)
      {
        int idx = _df2d.GetDistFncIndex (pcle.pos);
        if (idx < 0)
          continue;

        Vector<T,2> vel;
        CalculatePerPar (pcle, vel);
        _df2d.Update (idx, vel);
      }
      else
        _df3d.Update (pcle.pos, pcle.vel);
    }
  }

  if (_perpar)
    iomng.Write (_df2d, stime, GetTag ());
  else
    iomng.Write (_df2d, stime, GetTag ());

}

template <class T, int D>
void DistFncSensor<T,D>::CalculatePerPar (const TParticle &pcle,
                                          Vector<T,2> &vel) const
{
  Vector<T,3> bf;
  CartStencil::BilinearWeight (*_bfld, pcle.pos, bf);

  bf.Normalize ();
  vel[0] = pcle.vel * bf; // Parallel
  bf = pcle.vel % bf;
  vel[1] = bf.Norm (); // Perpendicular
}

/*******************/
/* Specialization: */
/*******************/

#define DISTFNCSENS_SPECIALIZE_DIM(type,dim)	\
  template class DistFncSensor<type,dim>;

#define DISTFNCSENS_SPECIALIZE(type)		\
  DISTFNCSENS_SPECIALIZE_DIM(type,1)		\
  DISTFNCSENS_SPECIALIZE_DIM(type,2)		\
  DISTFNCSENS_SPECIALIZE_DIM(type,3)

DISTFNCSENS_SPECIALIZE(float)
DISTFNCSENS_SPECIALIZE(double)
