/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   field.cxx
 * @brief  Field tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "satsimul.h"

#define DIM 2
#define LEN 5

SUITE (FieldSuite)
{
  TEST (SyncTest)
  {
    Mpi::Initialize (g_pargc, g_pargv);
    int iproc = Mpi::Rank ();
    int nproc = Mpi::Nodes ();

    Mesh<DIM> mesh;
    mesh.Initialize (Loc<DIM> (LEN),
		     Vector<double,DIM> (0.5),
		     Vector<double,DIM> (0.5),
		     Cell);

    CartDomDecomp<DIM> decomp;
    Loc<DIM> ratio = 1;
    decomp.Initialize (ratio, Mpi::COMM_WORLD);

    Layout<DIM> layout;
    layout.Initialize (Loc<DIM> (1), // ghost
		       Loc<DIM> (1), // share
		       Vector<bool,DIM> (true), // open BC
		       decomp);

    Field<Vector<float,3>,DIM> fld;
    fld.Initialize (mesh, layout);
    for (int j=LEN-1; j>-1; --j)
      for (int i=0; i<LEN; ++i)
	fld(i,j) = Vector<float,3> (iproc*.1+i+j);

    printf ("Process before: %d\n", iproc);
    for (int j=LEN-1; j>-1; --j)
    {
      for (int i=0; i<LEN; ++i)
	//printf ("%.1f ", fld(i));
      {
	const Vector<float,3> &vec = fld(i, j);
	printf ("%.1f;%.1f;%.1f ", vec[0], vec[1], vec[2]);
      }
      printf ("\n");
    }

    fld.Sync ();

    printf ("Process after: %d\n", iproc);
    for (int j=LEN-1; j>-1; --j)
    {
      for (int i=0; i<LEN; ++i)
	//printf ("%.1f ", fld(i));
      {
	const Vector<float,3> &vec = fld(i, j);
	printf ("%.1f;%.1f;%.1f ", vec[0], vec[1], vec[2]);
      }
      printf ("\n");
    }

    Mpi::Finalize ();
  }

  // TEST (AdjTest)
  // {
  //   Field<float, 2> fld (LEN, LEN);
  //   for (int i=0; i<LEN; ++i)
  //   {
  //     for (int j=0; j<LEN; ++j)
  //     {
  // 	fld(i,j) = (float)(i+(10*j));
  // 	printf ("%.1f ", fld(i,j));
  //     }
  //     printf ("\n");
  //   }

  //   Vector<float,4> adj;
  //   fld.GetAdj (Vector<int,2> (0,0), adj);
  //   for (int i=0; i<4; ++i)
  //     printf ("%f ", adj[i]);
  //   printf ("\n");
  // }
}
