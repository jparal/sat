/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wrap.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "wrap.h"

Mpi::Comm Mpi::s_comm     = (Mpi::Comm) 0;
int       Mpi::s_noutmsg  = 0;
int       Mpi::s_noutbyte = 0;
int       Mpi::s_ninmsg   = 0;
int       Mpi::s_ninbyte  = 0;
int       Mpi::s_isinit   = 0;
bool      Mpi::s_doabort  = true;

#ifdef HAVE_MPI
Mpi::Comm Mpi::COMM_WORLD = MPI_COMM_WORLD;
Mpi::Comm Mpi::COMM_NULL  = MPI_COMM_NULL;
#else
Mpi::Comm Mpi::COMM_WORLD = 0;
Mpi::Comm Mpi::COMM_NULL  = -1;
#endif

void Mpi::Initialize (int* argc, char*** argv)
{
#ifdef HAVE_MPI
  int test;
  // Determine if MPI has been initialized and init if needed
  MPI_Initialized (&test);
  if(!test)
    MPI_Init (argc,argv);
#else
  (void) argc;
  (void) argv;
#endif

  if (!s_isinit) {
    s_comm     = Mpi::COMM_WORLD;
    s_noutmsg  = 0;
    s_noutbyte = 0;
    s_ninmsg   = 0;
    s_ninbyte  = 0;
    s_isinit   = 1;
  }
}


void Mpi::Finalize ()
{
#ifdef HAVE_MPI
  if (s_isinit)
    MPI_Finalize();
#endif
}

/*
**************************************************************************
*                                                                        *
* Abort the program.                                                     *
*                                                                        *
**************************************************************************
*/
void Mpi::AbortOrExit (bool abort)
{
   s_doabort = abort;
}

void Mpi::Abort ()
{
#ifdef HAVE_MPI
  if (Nodes () > 1)
  {
    MPI_Abort (s_comm, -1);
  } else
  {
    if (s_doabort)
      ::abort ();
    else
      exit (-1);
  }
#else
  if (s_doabort)
    ::abort();
  else
    exit(-1);
#endif
}

/*
**************************************************************************
*                                                                        *
* Tree depth calculation for tracking the * number of message sends      *
* and receives and the number of bytes.                                  *
*                                                                        *
**************************************************************************
*/
int Mpi::TreeDepth ()
{
  int depth = 0;
  const int nnodes = Nodes ();
  while ((1 << depth) < nnodes) {
    depth++;
  }
  return depth;
}

/*
**************************************************************************
*                                                                        *
* Perform a global barrier across all processors.                        *
*                                                                        *
**************************************************************************
*/
void Mpi::Barrier ()
{
#ifdef HAVE_MPI
  (void) MPI_Barrier (s_comm);
  const int tree = TreeDepth ();
  UpdateOutflow (tree, 0);
  UpdateInflow  (tree, 0);
#endif
}
