/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   calcmom.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::CalcMom (TSpecie *sp, ScaField &dn, VecField &blk)
{
  dn = (T)0.;
  blk = (T)0.;

  BilinearWeightCache<T,D> cache;
  for (int pid=0; pid<sp->GetSize(); ++pid)
  {
    const TParticle &pcle = sp->Get (pid);

    FillCache (pcle.pos, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dn, cache, (T)1.);
    CartStencil::BilinearWeightAdd (blk, cache, pcle.vel);
  }

  dn.Sync ();
  blk.Sync ();
  if (_momsmooth && (_time.Iter() % _momsmooth == 0))
  {
    Smooth (dn);
    Smooth (blk);
  }
}
