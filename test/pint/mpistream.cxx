/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mpistream.cxx
 * @brief  Mpi I/O stream tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"
#include "sattest.h"

#define VDIM 3

SUITE (MpiStreamSuite)
{
  TEST (BeginTest)
  {
    Mpi::Initialize (g_pargc, g_pargv);
  }

  TEST (VectorStreamTest)
  {
    int iproc = Mpi::Rank ();
    int nproc = Mpi::Nodes ();
    typedef Vector<float,VDIM> TVector;

    if (iproc == 0)
    {
      for (int i=1; i<nproc; ++i)
      {
	MpiIStream<TVector> is(i, i);
	TVector vec;
	//	bool go = true;
	//	while (go);
	plog << i << ": ";
	for (int j=0; j<nproc; ++j)
	{
	  is >> vec;
	  plog << vec.Desc () << "  ";
	}
	plog << "\n";
      }
    }
    else // iproc != 0
    {
      MpiOStream<TVector> os (0,iproc);
      for (int j=0; j<nproc; ++j)
      {
	TVector vec (iproc+j);
	os << vec;
      }
    }
  }

  TEST (AllToOneTest)
  {
    //    Mpi::Initialize (g_pargc, g_pargv);

    int iproc = Mpi::Rank ();
    int nproc = Mpi::Nodes ();

    if (iproc ==0)
    {
      int val;
      for (int i=1; i<nproc; ++i)
      {
	MpiIStream<int> is(i, i);
	int nvals = 0;
	while (is.HasNext ())
	{
	  ++nvals;
	  is >> val;
	  //	  printf ("%d:%d ", nvals, val);
	  CHECK (val == i);
	}
	// printf ("\n");
	//	CHECK (nvals == (1.5+i)*MPISTREAM_BUFF_SIZE);
      }
      //      DBG_INFO ("Accepted [bytes]: "<<Mpi::InflowBytes ());
    }
    else
    {
      MpiOStream<int> os(0, iproc);
      int nvalues = (int)((1.5+iproc)*MPISTREAM_BUFF_SIZE);
      for (int j=0; j<nvalues; ++j)
	os << iproc;
    }

    //    Mpi::Finalize ();
  }

  TEST (EndTest)
  {
    Mpi::Finalize ();
  }
}
