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
  char fnamebuff[64];

  if (flags & suff)
    snprintf (fnamebuff, 64, "%s.h5", fname);
  else
    snprintf (fnamebuff, 64, "%s", fname);

  if (flags & app)
    _file = H5Fopen (fnamebuff, H5F_ACC_RDWR, H5P_DEFAULT);
  else
    _file = H5Fcreate (fnamebuff, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);
}

void HDF5File::Close ()
{
  H5Fclose(_file);
}
