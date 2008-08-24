/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   bwcache.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class T> SAT_INLINE
void FillCache (const Vector<T,1> &pos, BilinearWeightCache<T,1> &cache)
{
  int i = (int)Math::Floor (pos[0]);
  T xf = pos[0] - (T)i;
  T xa = (T)1. - xf;
  cache.ipos[0] = i;
  cache.weight[0] = xa;
  cache.weight[1] = xf;
}

template<class T> SAT_INLINE
void FillCache (const Vector<T,2> &pos, BilinearWeightCache<T,2> &cache)
{
  int i = (int)Math::Floor (pos[0]);
  int j = (int)Math::Floor (pos[1]);
  T xf = pos[0] - (T)i;
  T xa = (T)1.0 - xf;
  T yf = pos[1] - (T)j;
  T ya = (T)1.0 - yf;
  cache.ipos[0] = i;
  cache.ipos[1] = j;
  cache.weight[0] = xa * ya;
  cache.weight[1] = xf * ya;
  cache.weight[2] = xa * yf;
  cache.weight[3] = xf * yf;
}

template<class T> SAT_INLINE
void FillCache (const Vector<T,3> &pos, BilinearWeightCache<T,3> &cache)
{
  int i = (int)Math::Floor (pos[0]);
  int j = (int)Math::Floor (pos[1]);
  int k = (int)Math::Floor (pos[2]);
  T xf = pos[0] - (T)i;
  T xa = (T)1.0 - xf;
  T yf = pos[1] - (T)j;
  T ya = (T)1.0 - yf;
  T zf = pos[2] - (T)k;
  T za = (T)1.0 - zf;
  cache.ipos[0] = i;
  cache.ipos[1] = j;
  cache.ipos[2] = k;
  cache.weight[0] = xa * ya * za;
  cache.weight[1] = xf * ya * za;
  cache.weight[2] = xa * yf * za;
  cache.weight[3] = xf * yf * za;
  cache.weight[4] = xa * ya * zf;
  cache.weight[5] = xf * ya * zf;
  cache.weight[6] = xa * yf * zf;
  cache.weight[7] = xf * yf * zf;
}
