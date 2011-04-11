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
  /// Inject problem dependent particles
  static_cast<B*>(this)->InjectAdd (sp);

  TParticle pcle;
  size_t pid;

  T dt = _time.Dt ();
  const PosVector dxi = _meshp.GetResolInv ();
  RandomGen<T> &rnd = *(sp->GetRndGen());
  BiMaxwellRandGen<T> &max = *(sp->GetBiMaxwGen());
  Vector<T,3> v0 = sp->InitalVel();
  // @TODO deal with the types...
  const size_t npcles = (size_t)sp->InitalPcles ();

  for (int dim=0; dim<D; ++dim)
  {
    Domain<D> dom;
    for (int i=0; i<D; ++i)
      dom[i] = Range( 0, _meshp.GetCells( i )-2 );

    // Extend the domain to include the corners of simulation box
    for (int i=dim+1; i<D; ++i)
    {
      if (_layop.GetDecomp().IsLeftBnd( i ))
        dom[i].Lo()--;
      if (_layop.GetDecomp().IsRightBnd( i ))
        dom[i].Hi()++;
    }

    if (_layop.IsOpen( dim ) && _layop.GetDecomp().IsLeftBnd( dim ))
    {
      dom[dim] = Range( 0, 0 );

      DomainIterator<D> it( dom );
      do
      {
        PosVector loc = it.GetLoc();
        for (int ip=0; ip<npcles; ++ip)
        {
	  // The bug in random number generator prevents particles to be
	  // released from left boundary (probably repeating rand numbers).
          pcle.vel = v0 + max.Get();
          pcle.vel = v0 + max.Get();

          T r2 = rnd.Get();
          bool in = true;
          for (int i=0; i<D; ++i)
          {
            if (!in)
              continue;

            T r1 = (i==dim ? -1. : 1.) * rnd.Get();
            T pp = dt*pcle.vel[i]*dxi[i];
            T ll = r1 + loc[i] + pp;
            if (_pmin[i] < ll && ll < _pmax[i])
              pcle.pos[i] = (i==dim ? 0. : 1.) * r1 + loc[i] + pp * r2;
            else
              in = false;
          }

          if (in)
          {
            pid = sp->Push( pcle );
            sp->Exec( pid, PCLE_CMD_ARRIVED );
          }
        }
      }
      while (it.Next());
    }

    if (_layop.IsOpen( dim ) && _layop.GetDecomp().IsRightBnd( dim ))
    {
      dom[dim] = Range( _meshp.GetCells( dim )-1, _meshp.GetCells( dim )-1 );

      DomainIterator<D> it( dom );
      do
      {
        PosVector loc = it.GetLoc();
        for (int ip=0; ip<npcles; ++ip)
        {
          pcle.vel = v0 + max.Get();

          T r2 = rnd.Get();
          bool in = true;
          for (int i=0; i<D; ++i)
          {
            if (!in)
              continue;

            T r1 = rnd.Get();
            T pp = dt*pcle.vel[i]*dxi[i];
            T ll = r1 + loc[i] + pp;
            if (_pmin[i] < ll && ll < _pmax[i])
              pcle.pos[i] = (i==dim ? 0. : 1.) * r1 + loc[i] + pp * r2;
            else
              in = false;
          }

          if (in)
          {
            pid = sp->Push( pcle );
            sp->Exec( pid, PCLE_CMD_ARRIVED );
          }
        }
      }
      while (it.Next());

    }
  }
}
