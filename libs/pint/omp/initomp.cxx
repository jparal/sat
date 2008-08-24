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

  omp_set_dynamic (1);
  if (threads < 1)
    threads = omp_get_num_procs ();

  omp_set_num_threads (threads);
//   SAT::Log.Info ("OpenMP: num_threads %d", threads);

#endif /* HAVE_OMP */
}

// void SAT::OMP::Initialize (iConfigFile *icfg)
// {
// #ifdef SAT_OMP
//   int threads;

//   SAT_ASSERT (icfg != NULL);

//   omp_set_dynamic( 1 );
//   if (icfg->KeyExists (SCS_OMP_THREADS[0]))
//     threads = icfg->GetInt (SCS_OMP_THREADS[0]);
//   else
//     threads = omp_get_num_procs();

//   omp_set_num_threads (threads);
//   SAT::Log.Info ("OpenMP: num_threads %d", threads);
// #endif /* SAT_OMP */
// }
