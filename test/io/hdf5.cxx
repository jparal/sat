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
	  TYPE val = (TYPE)iproc*0.1 + (TYPE)(i+1)*100. + (TYPE)(j+1)*10 + (TYPE)(k+1);
	  fld (i, j, k) = val;
	}

    ConfigFile cfg;
    cfg.ReadFile ("hdf5.sin");
    XdmfFile file;
    file.Initialize (cfg);
    file.Write (fld, Cell, "Ppar", "pokusi0001");

    // /*****************/
    // /* Communicating */
    // /*****************/
    // if (iproc==0)
    // {
    //   hid_t file, fspace, fdataset, mspace, plist;
    //   hsize_t start[DIM], stride[DIM], count[DIM], block[DIM];
    //   Domain<DIM> dom;
    //   fld.GetDomain (dom);
    //   hsize_t domlen = dom.Length ();

    //   DBG_INFO ("Buff size: "<<sizeof(TYPE)*MPISTREAM_BUFF_SIZE<<"B");
    //   DBG_INFO ("# of elems: "<<(float)(nproc*domlen)/1000000<<"M");

    //   file = H5Fcreate (H5FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    //   // Select memory dataspace (common for all processors)
    //   mspace = H5Screate_simple(1, &domlen, NULL);
    //   start[0]  = 0;
    //   stride[0] = 1;
    //   count[0]  = domlen;
    //   block[0]  = 1;
    //   H5Sselect_hyperslab(mspace, H5S_SELECT_SET, start, stride, count, block);

    //   // Create file dataset
    //   hsize_t fdims[DIM], cdims[DIM];
    //   for (int i=0, j=DIM-1; i<DIM; ++i,--j)
    //   {
    // 	fdims[j] = (dims[i]-2*GHZ) * decomp.GetDim (i);
    // 	cdims[j] = dims[i]-2*GHZ;
    // 	//	printf ("%d ", (dims[i]-2*GHZ) * decomp.GetDim (i));
    //   }
    //   fspace = H5Screate_simple (DIM, fdims, NULL);

    //   plist = H5Pcreate (H5P_DATASET_CREATE);
    //   H5Pset_chunk (plist, DIM, cdims);
    //   H5Pset_shuffle (plist);
    //   H5Pset_deflate (plist, 6);

    //   fdataset = H5Dcreate2(file, H5DATA_NAME, H5T_NATIVE_FLOAT, fspace,
    // 			    H5P_DEFAULT, /**< Link creation property list */
    // 			    plist, /**< Dataset creation property list */
    // 			    H5P_DEFAULT); /**< Dataset access property list */

    //   /*************************************/
    //   /*************************************/
    //   TYPE val;
    //   CartDomDecomp<DIM> idecom;
    //   // Create memory dataset
    //   TYPE *data = (TYPE*)malloc (dom.Length () * sizeof(TYPE));

    //   for (int iprc=0; iprc<nproc; ++iprc)
    //   {
    // 	DomainIterator<DIM> iter (dom);
    // 	idecom.Initialize (ratio, Mpi::COMM_WORLD, iprc, nproc);

    // 	// Select file dataspace (unique for each processor)
    // 	for (int i=0, j=DIM-1; i<DIM; ++i, --j)
    // 	{
    // 	  start[j] = idecom.GetIdx (i) * dom[i].Length ();
    // 	  stride[j] = 1;
    // 	  count[j] = dom[i].Length ();
    // 	  block[j] = 1;
    // 	}

    // 	H5Sselect_hyperslab(fspace, H5S_SELECT_SET, start, stride, count, block);

    // 	/****************************************/
    // 	/****************************************/
    // 	TYPE *pdata = data;
    // 	if (iprc == 0)
    // 	{

    // 	  while (iter.HasNext ())
    // 	  {
    // 	    *pdata++ = fld (iter.GetLoc ());
    // 	    iter.Next ();
    // 	  }
    // 	}
    // 	else
    // 	{
    // 	  MpiIStream is (iprc, 0);
    // 	  for (int i=0; i<dom.Length (); ++i)
    // 	  {
    // 	    is >> val;
    // 	    *pdata++ = val;
    // 	  }
    // 	}

    // 	H5Dwrite (fdataset, H5T_NATIVE_FLOAT, mspace, fspace, H5P_DEFAULT, data);
    //   }

    //   // Close the hdf5 handlers
    //   H5Sclose (fspace);
    //   H5Sclose (mspace);
    //   H5Dclose (fdataset);
    //   H5Pclose(plist);
    //   H5Fclose(file);
    //   free (data);
    // }
    // else // iproc == 0
    // {
    //   /******************************/
    //   /* Send my data to iproc 0 */
    //   /******************************/
    //   Domain<DIM> dom;
    //   fld.GetDomain (dom);
    //   DomainIterator<DIM> iter (dom);
    //   MpiOStream os (0, 0);
    //   while (iter.HasNext ())
    //   {
    // 	os << fld (iter.GetLoc ());
    // 	iter.Next ();
    //   }
    // }

    Mpi::Finalize ();
  }
}
