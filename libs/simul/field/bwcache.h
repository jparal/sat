/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   bwcache.h
 * @brief  Cache for Bilinear weighting
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BWCACHE_H__
#define __SAT_BWCACHE_H__

#include "base/sys/inline.h"
#include "satmath.h"

/** @addtogroup simul_field
 *  @{
 */

template<class T, int D>
struct BilinearWeightCache
{
  Vector<int,D> ipos;
  Vector<float,MetaPow<2,D>::Is> weight;
};

/**
 * @brief Cache for Bilinear weighting
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D> SAT_INLINE
static void FillCache (const Vector<T,D> &pos, BilinearWeightCache<T,D> &cache);

#include "bwcache.cpp"

/** @} */

#endif /* __SAT_BWCACHE_H__ */
