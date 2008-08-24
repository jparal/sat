/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   initomp.h
 * @brief  OpenMP initialization
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_INITOMP_H__
#define __SAT_INITOMP_H__

#include "satconfig.h"
#include "base/sys/sysdefs.h"

/** @addtogroup pint_omp
 *  @{
 */

#ifdef HAVE_OMP
#  include <omp.h>
#endif /* HAVE_OMP */

#ifdef HAVE_OMP
#  define SAT_PRAGMA_OMP(p)       SAT_PRAGMA(omp p)

#else /* !HAVE_OMP */
#  define SAT_PRAGMA_OMP(p)
#endif /* HAVE_OMP */


struct Omp
{
  /** 
   * Initialize OpenMP support.
   * 
   * @param threads Number of thereads to run with.
   */
  static void Initialize (int threads);
};

/** @} */

#endif /* __SAT_INITOMP_H__ */
