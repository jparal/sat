/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filexdmf.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "simul/field/cartstencil.h"

#ifdef HAVE_HDF5
#include <hdf5.h>
#include "hdf5types.h"
#endif

template<class T, int D>
void XdmfFile::Write (const Field<T,D> &fld,
		      Centring center,
		      const char *tag, const char *fname)
{
  const Layout<D> &layout = fld.GetLayout ();
  const CartDomDecomp<D> &decomp = layout.GetDecomp ();
  const Mesh<D> &mesh = fld.GetMesh ();
  int iproc = decomp.GetIProc ();
  Domain<D> dom;
  fld.GetDomain (dom);

  bool average = false;

  if (fld.HaveGrid ())
  {
    if (mesh.Center () == Cell)
    {
      if (center == Node)
      {
	for (int i=0; i<D; ++i) dom[i].Lo () -= 1;
	average = true;
      }
    }
    else // if (mesh.Center () == Node)
    {
      if (center == Cell)
      {
	for (int i=0; i<D; ++i) dom[i].Hi () -= 1;
	average = true;
      }
    }
  }

  if (iproc==0)
  {
    hid_t file, fspace, fdataset, mspace, plist, type;
    hsize_t start[D], stride[D], count[D], block[D];
    hsize_t domlen = dom.Length ();
    type = HDF5TypeTraits<T>::GetID ();
    int nproc = decomp.GetNProc ();
    const Vector<int,D> &dims = fld.GetDims ();
    char fnamebuff[64];
    snprintf (fnamebuff, 64, "%s.h5", fname);

    file = H5Fcreate (fnamebuff, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    // Select memory dataspace (common for all processors)
    mspace = H5Screate_simple(1, &domlen, NULL);
    start[0]  = 0;
    stride[0] = 1;
    count[0]  = domlen;
    block[0]  = 1;
    H5Sselect_hyperslab(mspace, H5S_SELECT_SET, start, stride, count, block);

    // Create file dataset
    hsize_t fdims[D], cdims[D];
    for (int i=0, j=D-1; i<D; ++i,--j)
    {
      int domsize = dom[i].Length ();
      fdims[j] = domsize * decomp.GetSize (i);
      cdims[j] = domsize;
    }
    fspace = H5Screate_simple (D, fdims, NULL);

    if (_gz || _shuffle)
    {
      plist = H5Pcreate (H5P_DATASET_CREATE);
      H5Pset_chunk (plist, D, cdims);
      if (_shuffle) H5Pset_shuffle (plist);
      if (_gz) H5Pset_deflate (plist, _gz);
    }
    else
    {
      plist = H5P_DEFAULT;
    }

    fdataset = H5Dcreate (file, tag, type, fspace, plist);
    // H5P_DEFAULT, /**< Link creation property list */
    // plist, /**< Dataset creation property list */
    // H5P_DEFAULT); /**< Dataset access property list */

    /*************************************/
    /*************************************/
    T val;
    // Create memory dataset
    T *data = (T*)malloc (dom.Length () * sizeof(T));

    for (int iprc=0; iprc<nproc; ++iprc)
    {
      DomainIterator<D> iter (dom);

      // Select file dataspace (unique for each processor)
      for (int i=0, j=D-1; i<D; ++i, --j)
      {
	start[j] = decomp.GetPosition (i, iprc) * dom[i].Length ();
	stride[j] = 1;
	count[j] = dom[i].Length ();
	block[j] = 1;
      }

      H5Sselect_hyperslab(fspace, H5S_SELECT_SET, start, stride, count, block);

      /****************************************/
      /****************************************/
      T *pdata = data;
      if (iprc == 0)
      {
	while (iter.HasNext ())
	{
	  if (average)
	    CartStencil::Average (fld, iter, *pdata++);
	  else
	    *pdata++ = fld (iter);
	  iter.Next ();
	}
      }
      else // iprc != 0
      {
	int tag = 0;
	MpiIStream<T> is (iprc, tag);
	for (int i=0; i<dom.Length (); ++i)
	{
	  is >> val;
	  *pdata++ = val;
	}
      }

      H5Dwrite (fdataset, type, mspace, fspace, H5P_DEFAULT, data);
    }

    // Close the hdf5 handlers
    H5Sclose (fspace);
    H5Sclose (mspace);
    H5Dclose (fdataset);
    H5Pclose(plist);
    H5Fclose(file);
    free (data);
  }
  else // iproc != 0
  {
    /***************************/
    /* Send my data to iproc 0 */
    /***************************/
    int tag = 0;
    DomainIterator<D> iter (dom);
    MpiOStream<T> os (0, tag);
    T val;
    while (iter.HasNext ())
    {
      if (average)
	CartStencil::Average (fld, iter, val);
      else
	val = fld (iter);
      os << val;
      iter.Next ();
    }
  }
}


template<class T, int R, int D>
void XdmfFile::Write (const Field<Vector<T,R>,D> &fld,
		      Centring center,
		      const char *tag, const char *fname)
{
  const Layout<D> &layout = fld.GetLayout ();
  const CartDomDecomp<D> &decomp = layout.GetDecomp ();
  const Mesh<D> &mesh = fld.GetMesh ();
  int iproc = decomp.GetIProc ();
  Domain<D> dom;
  fld.GetDomain (dom);

  bool average = false;

  if (fld.HaveGrid ())
  {
    if (mesh.Center () == Cell)
    {
      if (center == Node)
      {
	for (int i=0; i<D; ++i) dom[i].Lo () -= 1;
	average = true;
      }
    }
    else // if (mesh.Center () == Node)
    {
      if (center == Cell)
      {
	for (int i=0; i<D; ++i) dom[i].Hi () -= 1;
	average = true;
      }
    }
  }

  if (iproc==0)
  {
    hid_t file, fspace, fdataset, mspace, plist, type;
    hsize_t start[D], stride[D], count[D], block[D];
    hsize_t domlen = dom.Length ();
    type = HDF5TypeTraits<T>::GetID ();
    int nproc = decomp.GetNProc ();
    const Vector<int,D> &dims = fld.GetDims ();
    char fnamebuff[64];
    snprintf (fnamebuff, 64, "%s.h5", fname);

    file = H5Fcreate (fnamebuff, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    // Select memory dataspace (common for all processors)
    mspace = H5Screate_simple(1, &domlen, NULL);
    start[0]  = 0;
    stride[0] = 1;
    count[0]  = domlen;
    block[0]  = 1;
    H5Sselect_hyperslab(mspace, H5S_SELECT_SET, start, stride, count, block);

    // Create file dataset
    hsize_t fdims[D], cdims[D];
    for (int i=0, j=D-1; i<D; ++i,--j)
    {
      int domsize = dom[i].Length ();
      fdims[j] = domsize * decomp.GetSize (i);
      cdims[j] = domsize;
    }
    fspace = H5Screate_simple (D, fdims, NULL);

    if (_gz || _shuffle)
    {
      plist = H5Pcreate (H5P_DATASET_CREATE);
      H5Pset_chunk (plist, D, cdims);
      if (_shuffle) H5Pset_shuffle (plist);
      if (_gz) H5Pset_deflate (plist, _gz);
    }
    else
    {
      plist = H5P_DEFAULT;
    }

    /*************************************/
    /*************************************/
    T val;
    // Create memory dataset
    T *data = (T*)malloc (dom.Length () * sizeof(T));

    for (int r=0; r<R; ++r)
    {
      char tagtmp[64];
      snprintf (tagtmp, 64, "%s%d", tag, r);
      fdataset = H5Dcreate (file, tagtmp, type, fspace, plist);
      // H5P_DEFAULT, /**< Link creation property list */
      // plist, /**< Dataset creation property list */
      // H5P_DEFAULT); /**< Dataset access property list */

      for (int iprc=0; iprc<nproc; ++iprc)
      {
	DomainIterator<D> iter (dom);

	// Select file dataspace (unique for each processor)
	for (int i=0, j=D-1; i<D; ++i, --j)
	{
	  start[j] = decomp.GetPosition (i, iprc) * dom[i].Length ();
	  stride[j] = 1;
	  count[j] = dom[i].Length ();
	  block[j] = 1;
	}

	H5Sselect_hyperslab(fspace, H5S_SELECT_SET, start, stride, count, block);

	/****************************************/
	/****************************************/
	T *pdata = data;
	Vector<T,R> tmp;
	if (iprc == 0)
	{
	  while (iter.HasNext ())
	  {
	    if (average)
	      CartStencil::Average (fld, iter, tmp);
	    else
	      tmp = fld (iter);

	    *pdata++ = tmp[r];
	    iter.Next ();
	  }
	}
	else
	{
	  int tag = 0;
	  MpiIStream<T> is (iprc, tag);
	  for (int i=0; i<dom.Length (); ++i)
	  {
	    is >> val;
	    *pdata++ = val;
	  }
	}

	H5Dwrite (fdataset, type, mspace, fspace, H5P_DEFAULT, data);
      }
      H5Dclose (fdataset);
    }

    // Close the hdf5 handlers
    H5Sclose (fspace);
    H5Sclose (mspace);
    H5Pclose(plist);
    H5Fclose(file);
    free (data);
  }
  else // iproc != 0
  {
    /***************************/
    /* Send my data to iproc 0 */
    /***************************/
    Vector<T,R> val;

    for (int r=0; r<R; ++r)
    {
      int tag = 0;
      MpiOStream<T> os (0, tag);
      DomainIterator<D> iter (dom);
      while (iter.HasNext ())
      {
	if (average)
	  CartStencil::Average (fld, iter, val);
	else
	  val = fld (iter);
	os << val[r];
	iter.Next ();
      }
    }
  }
}
