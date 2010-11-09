/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   camspecie.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "camspecie.h"
#include "math/rand/bimaxwell.h"
#include "math/rand/maxwell.h"
#include "simul/field/cartstencil.h"

template<class T, int D>
void CamSpecie<T,D>::Initialize (const ConfigEntry &cfg,
				 const Mesh<D> mesh,
				 const Layout<D> layout)
{
  _name = cfg.GetName ();
  _mesh = mesh;
  Specie<T,D>::Initialize (layout);

  try
  {
    cfg.GetValue ("pcles", _ng);
    cfg.GetValue ("beta", _beta);
    cfg.GetValue ("rmds", _rmds);
    cfg.GetValue ("qms", _qms);
    cfg.GetValue ("v0", _vs);
    if (cfg.Exists ("ani"))
    {
      T ani;
      cfg.GetValue ("ani", ani);
      _rvth = Math::Sqrt (ani);
    }
    else
    {
      cfg.GetValue ("rvth", _rvth);
    }
  }
  catch (ConfigFileException &exc)
  {
    DBG_ERROR ("Specie::Initialize: exception during: "<<
	       cfg.GetPath ());
  }

  /// Number 2 in denominator is there when v_th doesn't include factor 2 in
  /// definition of Maxwell distribution
  _vthpa = Math::Sqrt (_beta / (2.*_rmds));
  _vthpe = _rvth * _vthpa;

  _sm = _rmds / _ng;
  _sq = _qms * _sm;

  DBG_INFO ("  number of pcles per cell    : "<< InitalPcles ());
  DBG_INFO ("  charge over mass (q/m)      : "<< ChargeMassRatio ());
  DBG_INFO ("  charge per particle (sq)    : "<< ChargePerPcle ());
  DBG_INFO ("  mass per particle (sm)      : "<< MassPerPcle ());
  DBG_INFO ("  rel. mass dens. (rmsd)      : "<< RelMassDens ());
  DBG_INFO ("  specie beta (beta)          : "<< Beta ());
  DBG_INFO ("  vth_per/vth_par = rvth (A)  : "
	     << Vthper () << "/"<< Vthpar () << " = " << RatioVth ()
	     << " (A = " << _rvth*_rvth << ")");
  DBG_INFO ("  initial velocity (v0)       : "<< InitalVel ());
}

template<class T, int D>
void CamSpecie<T,D>::LoadPcles (const Field<T,D> &dn,
				const Field<Vector<T,3>,D> &u,
				const Field<Vector<T,3>,D> &b,
				const Field<T,D> &vthper,
				const Field<T,D> &vthpar,
				Vector<T,3> b0)
{
  TParticle pcle;
  Vector<T,3> bb;
  T vper, vpar;

  Domain<D> dom;
  for (int i=0; i<D; ++i)
    // Go from 0 .. number of vertexes - 2
    dom[i] = Range( 0, _mesh.GetCells (i) - 2 );

  BilinearWeightCache<T,D> cache;
  DomainIterator<D> it (dom);
  do
  {
    T dnl;
    CartStencil::Average (dn, it, dnl);
    int np = (int)(dnl * _ng);

    for (int i=0; i<np; ++i)
    {
      for (int j=0; j<D; ++j)
	pcle.pos[j] = _rnd.Get () + (T)it.GetLoc (j);

      FillCache (pcle.pos, cache);
      CartStencil::BilinearWeight (b, pcle.pos, bb);
      cache.ipos += 1;
      CartStencil::BilinearWeight (vthper, pcle.pos, vper);
      CartStencil::BilinearWeight (vthpar, pcle.pos, vpar);
      bb.Normalize ();
      _bimax.Initialize (bb, vper, vpar);

      CartStencil::BilinearWeight (u, pcle.pos, pcle.vel);
      pcle.vel += _bimax.Get ();

      this->Push (pcle);
    }
  }
  while (it.Next ());

  _bimax.Initialize (b0, Vthper(), Vthpar());
}

/*******************/
/* Specialization: */
/*******************/

#define CAMSPECIE_SPECIALIZE_DIM(type,dim) \
  template class CamSpecie<type,dim>;

#define CAMSPECIE_SPECIALIZE(type) \
  CAMSPECIE_SPECIALIZE_DIM(type,1) \
  CAMSPECIE_SPECIALIZE_DIM(type,2) \
  CAMSPECIE_SPECIALIZE_DIM(type,3)

CAMSPECIE_SPECIALIZE(float)
CAMSPECIE_SPECIALIZE(double)
