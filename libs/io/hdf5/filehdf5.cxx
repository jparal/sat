/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filehdf5.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/12, @jparal}
 * @revmessg{Initial version}
 */

#include "filehdf5.h"

void HDF5File::Open (const char *fname, IOFile::Flags flags)
{
  String namebuf (fname);

  if (Separate ())
  {
    namebuf.Append ("_");
    namebuf.Append (Mpi::Rank ());
  }

  if (flags & suff)
    namebuf.Append (".h5");

#ifdef HAVE_HDF5_PARALLEL
  if (Parallel ())
  {
    hid_t pfopen;
    Mpi::Comm comm = Mpi::COMM_WORLD;

    MPI_Info info = MPI_INFO_NULL;
    // MPI_Info info; //Commented by Belaid = MPI_INFO_NULL;
    // MPI_Info_create(&info);
    // MPI_Info_set(info, "romio_ds_read", "disable");
    // MPI_Info_set(info, "romio_ds_write", "disable");
    // MPI_Info_set(info, "romio_cb_read", "enable");
    // MPI_Info_set(info, "romio_cb_write", "enable");

    pfopen = H5Pcreate (H5P_FILE_ACCESS);
    H5Pset_fapl_mpio (pfopen, comm, info);

    if (flags & app)
      _file = H5Fopen (namebuf, H5F_ACC_RDWR, pfopen);
    else
      _file = H5Fcreate (namebuf, H5F_ACC_TRUNC, H5P_DEFAULT, pfopen);

    H5Pclose (pfopen);
  }
  else
#endif /* HAVE_HDF5_PARALLEL */
  {
    if (Serial () && Mpi::Rank() != 0)
      return;

    if (flags & app)
      _file = H5Fopen (namebuf, H5F_ACC_RDWR, H5P_DEFAULT);
    else
      _file = H5Fcreate (namebuf, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
  }
}

void HDF5File::Close ()
{
#ifdef HAVE_HDF5_PARALLEL
  if (Parallel ())
  {
    if (_file)
      H5Fclose(_file);
  }
  else
#endif /* HAVE_HDF5_PARALLEL */
  {
    if (Serial () && Mpi::Rank() != 0)
      return;

    if (_file)
      H5Fclose(_file);
  }

  _file = 0;
}
