/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   writehdf5.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "simul/field/cartstencil.h"
#include "pint/mpi/streammpi.h"

#ifdef HAVE_HDF5
#include <hdf5.h>
#include "hdf5types.h"
#endif

template<class T, int D>
void HDF5File::Write (const Field<T,D> &fld, const char *tag)
{
  size_t len = GetWritableDomain(fld).Length ();
  T *data = (T*)malloc (len * sizeof(T));

  if (Serial ())
  {
    int iproc = fld.GetLayout().GetDecomp().GetIProc ();
    int nproc = fld.GetLayout().GetDecomp().GetNProc ();
    if (iproc == 0)
    {
      for (int iprc=0; iprc<nproc; ++iprc)
      {
        if (iprc == 0)
          CopyData (data, fld);
        else
          ReceiveData (data, len, iprc);

        WriteChunk (data, fld, tag, iprc, -1);
      }
    }
    else
    {
      CopyData (data, fld);
      SendData (data, len);
    }
  }
  else if (Separate ())
  {
    CopyData (data, fld);
    WriteChunk (data, fld, tag, -1, -1);
  }
#ifdef HAVE_HDF5_PARALLEL
  if (Parallel ())
  {
    CopyData (data, fld);
    WriteChunk (data, fld, tag, -1, -1);
  }
  else
#endif /* HAVE_HDF5_PARALLEL */

  free (data);
}

template<class T, int R, int D>
void HDF5File::Write (const Field<Vector<T,R>,D> &fld, const char *tag)
{
  size_t len = GetWritableDomain(fld).Length ();
  T *data = (T*)malloc (len * sizeof(T));

  if (Serial ())
  {
    int iproc = fld.GetLayout().GetDecomp().GetIProc ();
    int nproc = fld.GetLayout().GetDecomp().GetNProc ();
    if (iproc == 0)
    {
      for (int rank=0; rank<R; ++rank)
      {
        for (int iprc=0; iprc<nproc; ++iprc)
        {
          if (iprc == 0)
            CopyData (data, fld, rank);
          else
            ReceiveData (data, len, iprc);

          WriteChunk (data, fld, tag, iprc, rank);
        }
      }
    }
    else
    {
      for (int rank=0; rank<R; ++rank)
      {
        CopyData (data, fld, rank);
        SendData (data, len);
      }
    }
  }
  else if (Separate ())
  {
    for (int rank=0; rank<R; ++rank)
    {
      CopyData (data, fld, rank);
      WriteChunk (data, fld, tag, -1, rank);
    }
  }
#ifdef HAVE_HDF5_PARALLEL
  else if (Parallel ())
  {
    for (int rank=0; rank<R; ++rank)
    {
      CopyData (data, fld, rank);
      WriteChunk (data, fld, tag, -1, rank);
    }
  }
#endif /* HAVE_HDF5_PARALLEL */

  free (data);
}

template<class T>
void HDF5File::ReceiveData (T *data, size_t len, int iprc)
{
  T val;
  int tag = 0;
  MpiIStream<T> is (iprc, tag);
  for (int i=0; i<len; ++i)
  {
    is >> val;
    *data++ = val;
  }
}

template<class T>
void HDF5File::SendData (T *data, size_t len)
{
  int tag = 0;
  T val;
  MpiOStream<T> os (0, tag);
  for (int i=0; i<len; ++i)
  {
    val = *data++;
    os << val;
  }
}

template<class T, class T2, int D>
void HDF5File::WriteChunk (T *data, const Field<T2,D> &fld, const char *tag,
                           int iprc, int rank)
{
  const Layout<D> &layout = fld.GetLayout ();
  const Mesh<D> &mesh = fld.GetMesh ();
  const CartDomDecomp<D> &decomp = layout.GetDecomp ();
  Domain<D> dom = GetWritableDomain (fld);

  char tagtmp[64];
  if (rank < 0)
    snprintf (tagtmp, 64, "%s", tag);
  else
    snprintf (tagtmp, 64, "%s%d", tag, rank);

  if (iprc < 0)
    iprc = decomp.GetIProc ();

  hid_t fspace, fdataset, mspace, plist, type;
  hsize_t start[D], stride[D], count[D], block[D];
  hsize_t domlen = dom.Length ();
  type = HDF5TypeTraits<T>::GetID ();

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
    fdims[j] = domsize * (Separate () ? 1 :decomp.GetSize (i));
    cdims[j] = domsize;
  }
  fspace = H5Screate_simple (D, fdims, NULL);

  if ((Gzip() || Shuffle()) && !Parallel ())
  {
    // @TODO I create plist here but in the other branch of this condition I
    //       just assign a value: is this correct?
    plist = H5Pcreate (H5P_DATASET_CREATE);
    H5Pset_chunk (plist, D, cdims);

    if (Shuffle ())
      H5Pset_shuffle (plist);
    if (Gzip ())
      H5Pset_deflate (plist, Gzip());
  }
  else
  {
    plist = H5P_DEFAULT;
  }

  // Select file dataspace (unique for each processor)
  for (int i=0, j=D-1; i<D; ++i, --j)
  {
    int pos = Separate () ? 0 : decomp.GetPosition (i, iprc);
    start[j] = dom[i].Length () * pos;
    stride[j] = 1;
    count[j] = dom[i].Length ();
    block[j] = 1;
  }

  H5Sselect_hyperslab(fspace, H5S_SELECT_SET, start, stride, count, block);

#ifdef HAVE_HDF5_PARALLEL
  if (Parallel ())
  {
    hid_t pdatxfer;
    pdatxfer = H5Pcreate (H5P_DATASET_XFER);
    H5Pset_dxpl_mpio (pdatxfer, H5FD_MPIO_COLLECTIVE);

    fdataset = H5Dcreate (_file, tagtmp, type, fspace, plist);
    H5Dwrite (fdataset, type, mspace, fspace, pdatxfer, data);

    H5Pclose(pdatxfer);
  }
  else
#endif /* HAVE_HDF5_PARALLEL */
  {
    if (Separate () || iprc == 0)
      fdataset = H5Dcreate (_file, tagtmp, type, fspace, plist);
    else
      fdataset = H5Dopen (_file, tagtmp);

    H5Dwrite (fdataset, type, mspace, fspace, H5P_DEFAULT, data);
  }

  H5Dclose (fdataset);
  H5Sclose (fspace);
  H5Sclose (mspace);
  H5Pclose (plist);
}

template<class T, int D>
void HDF5File::CopyData (T *data, const Field<T,D> &fld)
{
  Domain<D> dom = GetWritableDomain (fld);
  DomainIterator<D> it (dom);
  do
  {
    *data++ = fld (it);
  }
  while (it.Next ());
}

template<class T, int R, int D>
void HDF5File::CopyData (T *data, const Field<Vector<T,R>,D> &fld, int rank)
{
  Domain<D> dom = GetWritableDomain (fld);
  DomainIterator<D> it (dom);
  do
  {
    *data++ = fld(it)[rank];
  }
  while (it.Next ());
}

template<class T, int D>
Domain<D> HDF5File::GetWritableDomain (const Field<T,D> &fld)
{
  Domain<D> dom;
  fld.GetDomain (dom);
  if (fld.GetMesh().Center () == Node)
    dom.HiAdd (-1);
  return dom;
}

template<class T>
void HDF5File::Write (const Array<T> &arr, const char *tag)
{
  hid_t fspace, fdataset, mspace, plist, type;
  hsize_t start[1], stride[1], count[1], block[1];
  type = HDF5TypeTraits<T>::GetID ();
  hsize_t domlen = arr.GetSize ();

  // Select memory dataspace (common for all processors)
  mspace = H5Screate_simple(1, &domlen, NULL);
  start[0]  = 0;
  stride[0] = 1;
  count[0]  = arr.GetSize ();
  block[0]  = 1;
  H5Sselect_hyperslab(mspace, H5S_SELECT_SET, start, stride, count, block);

  // Create file dataset
  hsize_t fdims[1], cdims[1];
  fdims[0] = arr.GetSize ();
  cdims[0] = arr.GetSize ();

  fspace = H5Screate_simple (1, fdims, NULL);

  if (Gzip() || Shuffle())
  {
    plist = H5Pcreate (H5P_DATASET_CREATE);
    H5Pset_chunk (plist, 1, cdims);
    if (Shuffle()) H5Pset_shuffle (plist);
    if (Gzip()) H5Pset_deflate (plist, Gzip());
  }
  else
  {
    plist = H5P_DEFAULT;
  }

  fdataset = H5Dcreate (_file, tag, type, fspace, plist);
  // H5P_DEFAULT, /**< Link creation property list */
  // plist, /**< Dataset creation property list */
  // H5P_DEFAULT); /**< Dataset access property list */

  /*************************************/
  /*************************************/
  start[0] = 0;
  stride[0] = 1;
  count[0] = arr.GetSize ();
  block[0] = 1;

  H5Sselect_hyperslab (fspace, H5S_SELECT_SET, start, stride, count, block);

  /****************************************/
  /****************************************/
  H5Dwrite (fdataset, type, mspace, fspace, H5P_DEFAULT, arr.GetData ());

  // Close the hdf5 handlers
  H5Sclose (fspace);
  H5Sclose (mspace);
  H5Dclose (fdataset);
  H5Pclose (plist);
}
