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
  RandomGen<T> &rnd = *(sp->GetRndGen());
  BiMaxwellRandGen<T> &max = *(sp->GetBiMaxwGen());
  Vector<float,3> v0 = sp->InitalVel();
  const size_t npcles = sp->InitalPcles();

  for (int dim=0; dim<D; ++dim)
  {
    Domain<D> dom;
    for (int i=0; i<D; ++i)
      dom[i] = Range( 0, _meshp.GetCells( i )-1 );

    if (_layop.IsOpen( dim ) && _layop.GetDecomp().IsLeftBnd( dim ))
    {
      dom[dim] = Range( 0, 0 );

      DomainIterator<D> it( dom );
      while (it.HasNext())
      {
	for (int pp=0; pp<npcles; ++pp)
	{
	  pcle.vel = v0 + max.Get();
	  if (-(rnd.Get()) + dt*pcle.vel[dim]*dxi[dim] > 0.)
	  {
	    for (int j=0; j<D; ++j)
	      pcle.pos[j] = (T)it.GetLoc(j) + dt*pcle.vel[j]*dxi[j]*rnd.Get();

	    pid = sp->Push( pcle );
	    sp->Exec( pid, PCLE_CMD_ARRIVED );
	  }
	}
	it.Next();
      }
    }

    if (_layop.IsOpen( dim ) && _layop.GetDecomp().IsRightBnd( dim ))
    {
      dom[dim] = Range( _meshp.GetCells( dim )-1, _meshp.GetCells( dim )-1 );

      DomainIterator<D> it( dom );
      while (it.HasNext())
      {
	for (int pp=0; pp<npcles; ++pp)
	{
	  pcle.vel = v0 + max.Get();
	  if (rnd.Get() + dt*pcle.vel[dim]*dxi[dim] < 0.)
	  {
	    for (int j=0; j<D; ++j)
	      pcle.pos[j] = (T)it.GetLoc(j) + dt*pcle.vel[j]*dxi[j]*rnd.Get();

	    pid = sp->Push( pcle );
	    sp->Exec( pid, PCLE_CMD_ARRIVED );
	  }
	}
	it.Next();
      }
    }

  }
}
