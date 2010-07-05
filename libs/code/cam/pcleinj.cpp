/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pclinj.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/06, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::Inject (TSpecie *sp, ScaField &dn, VecField &us)
{
  TParticle pcle;
  size_t pid;

  T dt = _time.Dt ();
  const PosVector dxi = _meshp.GetResolInv ();
  Vector<float,3> v0 = sp->InitalVel();

  for (int pp = 0; pp < sp->InitalPcles(); ++pp)
  {
    pcle.vel = sp->InitalVel() + sp->GetBiMaxwGen()->Get();
    if (-(sp->GetRndGen()->Get()) + dt*pcle.vel[0]*dxi[0] > 0.)
    {
      pcle.pos[0] = _pmin[0] + dt*pcle.vel[0]*dxi[0]*sp->GetRndGen()->Get();
      pid = sp->Push( pcle );
      sp->Exec( pid, PCLE_CMD_ARRIVED );
    }

    pcle.vel = sp->InitalVel() + sp->GetBiMaxwGen()->Get();
    if (sp->GetRndGen()->Get() + dt*pcle.vel[0]*dxi[0] < 0.)
    {
      pcle.pos[0] = _pmax[0] + dt*pcle.vel[0]*dxi[0]*sp->GetRndGen()->Get();
      pid = sp->Push( pcle );
      sp->Exec( pid, PCLE_CMD_ARRIVED );
    }
  }
}
