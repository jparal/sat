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

#include "satbase.h"

/** @addtogroup pint_omp
 *  @{
 */

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

  static void PrintInfo ();
};

/** @} */

#endif /* __SAT_INITOMP_H__ */
