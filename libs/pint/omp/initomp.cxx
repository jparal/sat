/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   initomp.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#include "initomp.h"

void Omp::Initialize (int threads)
{
#ifdef HAVE_OMP

  // It seems that by OpenMP standard omp_set_dynamic(TRUE) let the system
  // decide how many threads to allocate at the beginning of each parallel
  // section and thus the number of threads is changing.
  // We want to have a control over the number so set to FALSE.
  // NOTE: ICC compiler has the opposite behavior.
  omp_set_dynamic (0);

  if (threads < 1)
  {
    threads = omp_get_num_procs ();
  }

  omp_set_num_threads (threads);

  Omp::PrintThreads (threads);

#endif // HAVE_OMP
}

void Omp::Initialize (ConfigFile& cfg)
{
#ifdef HAVE_OMP
  int threads;

  // See the note in Omp::Initialize()
  omp_set_dynamic (0);

  cfg.GetValue ("parallel.omp.threads", threads, -1);
  if (threads < 1)
  {
    threads = omp_get_num_procs ();
  }
  omp_set_num_threads (threads);

  Omp::PrintThreads (threads);

#endif // HAVE_OMP
}

void Omp::PrintThreads (int threads)
{
  DBG_INFO ("OpenMP: number of threads: " << threads);
}
