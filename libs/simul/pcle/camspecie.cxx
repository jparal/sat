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
#include "math/rand/maxwgen.h"
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
    cfg.GetValue ("rvth", _rvth);
    cfg.GetValue ("rmds", _rmds);
    cfg.GetValue ("qms", _qms);
    cfg.GetValue ("v0", _vs);
  }
  catch (ConfigFileException &exc)
  {
    DBG_ERROR ("Specie::Initialize: exception during: "<<
	       cfg.GetPath ());
  }

  T rvth2 = _rvth*_rvth;
  _vthpa = Math::Sqrt (_beta / (_rmds * (1 + rvth2)));
  _vthpe = Math::Sqrt ((rvth2 * _beta) / (2. * _rmds * (1 + rvth2)));

  // _vthpa = Math::Sqrt (_beta / _rmds);
  // _vthpe = _rvth * _vthpa;

  _sm = _rmds / _ng;
  _sq = _qms * _sm;

  DBG_INFO1 ("  charge per particle (sq) = "<< ChargePerPcle ());
  DBG_INFO1 ("  mass per particle (sm)   = "<< MassPerPcle ());
  DBG_INFO1 ("  specie beta (beta)       = "<< Beta ());
  DBG_INFO1 ("  rel. mass dens. (rmsd)   = "<< RelMassDens ());
  DBG_INFO1 ("  vth_per/vth_par == rvth  = "
	     << Vthper () << "/"<< Vthpar () << " == " << RatioVth ());
  DBG_INFO1 ("  initial velocity (v0)    = "<< InitalVel ());
}

template<class T, int D>
void CamSpecie<T,D>::LoadPcles (const Field<T,D> &dn,
				const Field<Vector<T,3>,D> &u, Vector<T,3> b)
{
  float bb;
  T vpar, vper1, vper2;
  Vector<float,3> v1, v2;
  TParticle pcle;
  T dnl;
  Vector<T,D> pos;
  int np;

  b.Normalize ();

  bb = Math::Sqrt (b[1]*b[1] + b[2]*b[2]);
  if (bb > 0.05)
  {
    v1[0] = 0.;
    v1[1] =   b[2] / bb;
    v1[2] = - b[1] / bb;
  }
  else
  {
    bb = Math::Sqrt (b[0]*b[0] + b[1]*b[1]);
    v1[0] =   b[1] / bb;
    v1[1] = - b[0] / bb;
    v1[2] = 0.;
  }
  v2 = b % v1;

  MaxwellRandGen<T> maxwpa (Vthpar ());
  MaxwellRandGen<T> maxwpe (Vthper ());

  Domain<D> dom;
  for (int i=0; i<D; ++i)
    // Go from 0 .. number of vertexes - 2
    dom[i] = Range (0, _mesh.GetDim (i)-2);

  DomainIterator<D> it (dom);
  while (it.HasNext ())
  {
    CartStencil::Average (dn, it, dnl);
    np = (int)(dnl * _ng);

    for (int i=0; i<np; ++i)
    {
      for (int j=0; j<D; ++j)
	pos[j] = _rnd.Get () + (T)it.GetLoc (j);

      vper1 = maxwpe.Get ();
      vper2 = maxwpe.Get ();
      vpar  = maxwpa.Get ();

      pcle.pos = pos;
      CartStencil::BilinearWeight (u, pos, pcle.vel);
      pcle.vel += b * vpar + v1 * vper1 + v2 * vper2;

      Push (pcle);
    }

    it.Next ();
  }
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
