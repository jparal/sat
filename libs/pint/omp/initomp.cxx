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
#ifdef HAVE_OPENMP

  // It seems that by OpenMP standard omp_set_dynamic(TRUE) let the system
  // decide how many threads to allocate at the beginning of each parallel
  // section and thus the number of threads is changing.  We want to have a
  // control over the number so set omp_set_dynamic to FALSE.
  // NOTE: ICC compiler has the opposite behavior.
  omp_set_dynamic (0);

  if (threads < 1)
  {
    threads = omp_get_num_procs ();
  }

  omp_set_num_threads (threads);

#endif // HAVE_OPENMP

  Omp::PrintInfo ();
}

void Omp::Initialize (ConfigFile& cfg)
{
  int threads;

#ifdef HAVE_OPENMP

  // See the note in Omp::Initialize()
  omp_set_dynamic (0);

  cfg.GetValue ("parallel.omp.threads", threads, -1);
  if (threads < 1)
  {
    threads = omp_get_num_procs ();
  }
  omp_set_num_threads (threads);

#endif // HAVE_OPENMP

  Omp::PrintInfo ();
}

void Omp::PrintInfo ()
{
#ifdef HAVE_OPENMP
  DBG_INFO ("OpenMP Initialization");
  SAT_PRAGMA_OMP (parallel)
  {
    if (omp_get_thread_num () == 0)
      DBG_INFO ("  omp_get_num_threads: " << omp_get_num_threads ());
  }
  DBG_INFO1 ("  omp_get_max_threads: " << omp_get_max_threads ());
  DBG_INFO1 ("  omp_get_num_procs:   " << omp_get_num_procs ());
  DBG_INFO1 ("  omp_get_dynamic:     " << omp_get_dynamic ());
#else
  DBG_WARN ("OpenMP: Support is not compiled in!");
#endif // HAVE_OPENMP
}
