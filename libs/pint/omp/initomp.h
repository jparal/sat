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
#include "satbase.h"

/** @addtogroup pint_omp
 *  @{
 */

#ifdef HAVE_OMP
#  include <omp.h>
#  define SAT_PRAGMA_OMP(p) SAT_PRAGMA(omp p)
#else
#  define SAT_PRAGMA_OMP(p)
#endif // HAVE_OMP

struct Omp
{
  /**
   * @brief Initialize OpenMP support.
   * If value is missing of the value is less then 1 then set up the number of
   * threads to the number of available processors.
   *
   * @param threads Number of thereads to run with.
   */
  static void Initialize (int threads);

  /**
   * @brief Initialize OpenMP support from ConfigFile.
   * Read @e parallel.omp.threads variable from configuration file. If value is
   * missing of the value is less then 1 then set up the number of threads to
   * the number of available processors.
   */
  static void Initialize (ConfigFile& cfg);

  void PrintThreads (int threads);
};

/** @} */

#endif /* __SAT_INITOMP_H__ */
