/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hdf5.cxx
 * @brief  HDF5 Test
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "sat.h"

#include "hdf5.h"

#define H5FILE_DIR "out/0001"
#define H5FILE_NAME "out.h5"
#define H5DATA_NAME "Dn"
#define LEN 150
#define GHZ 0
#define DIM 3
#define TYPE double

SUITE (HDF5Suite)
{
  TEST (WriteTest)
  {
    Mpi::Initialize (g_pargc, g_pargv);
    int iproc = Mpi::Rank ();
    int nproc = Mpi::Nodes ();

    /*******************/
    /* Creating Field: */
    /*******************/
    Mesh<DIM> mesh;
    Loc<DIM> dims (LEN);
    // for (int i=0; i<DIM; ++i) dims[i] += i;
    mesh.Initialize (dims, /**< Dimensions */
		     Vector<double,DIM> (0.5), /**< spacings */
                     Vector<double,DIM> (0.),	/**< origin */
		     Cell);

    CartDomDecomp<DIM> decomp;
    Loc<DIM> ratio (1);
    decomp.Initialize (ratio, Mpi::COMM_WORLD);

    Layout<DIM> layout;
    layout.Initialize (Loc<DIM> (GHZ), /**< Ghost zones */
		       Loc<DIM> (0), /**< shared zone */
		       Vector<bool,DIM> (false), /**< Is boundary open? */
		       decomp); 	/**< Domain decomposition */


    Field<TYPE,DIM> fld;
    fld.Initialize (mesh, layout);
    for (int k=0; k<dims[2]; ++k)
      for (int j=0; j<dims[1]; ++j)
	for (int i=0; i<dims[0]; ++i)
	{
	  TYPE val =
	    (TYPE)iproc*0.1 +
	    (TYPE)(i+1)*100. +
	    (TYPE)(j+1)*10 +
	    (TYPE)(k+1);
	  fld (i, j, k) = val;
	}

    ConfigFile cfg;
    cfg.ReadFile ("hdf5.sin");
    HDF5File file;
    file.Initialize (cfg);
    file.Write (fld, Cell, "Ppar", "pokusi0001");

    Mpi::Finalize ();
  }
}
