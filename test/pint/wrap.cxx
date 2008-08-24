/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wrap.cxx
 * @brief  Tests of Mpi wrapping class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "pint/satmpi.h"

SUITE (MpiSuite)
{
  TEST (WrapTest)
  {
    Mpi::Initialize (g_pargc, g_pargv);
    double d = 2.3;
    double starttime, endtime; 
    starttime = MPI_Wtime();
    for (int i=0; i<1000; ++i)
    {
      d += d / 1.23;
    }
    endtime   = MPI_Wtime(); 
    Mpi::Finalize ();
    printf("That took %f seconds\n",endtime-starttime);
  }
}
