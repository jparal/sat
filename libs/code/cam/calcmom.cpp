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
  dn = 0.;
  blk = FldVector (0.);

  BilinearWeightCache<T,D> cache;
  TSpecieIterator it = sp->GetIterator ();
  while (it.HasNext ())
  {
    const TParticle &pcle = it.Next ();

    FillCache (pcle.pos, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dn, cache, (T)1.);
    CartStencil::BilinearWeightAdd (blk, cache, pcle.vel);
  }
}
