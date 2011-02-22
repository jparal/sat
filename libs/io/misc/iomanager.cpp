/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   iomanager.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "io/misc/fmanip.h"

template<class T, int D>
void IOManager::Write (Field<T,D> &fld, const SimulTime &stime, const char *tag)
{
  String fname = GetFileName (tag, stime);

  _file->Open (fname, IOFile::suff);

  switch (_format)
  {
  case IO_FORMAT_XDMF:
  case IO_FORMAT_HDF5:
    ((HDF5File*)_file)->Write (fld, tag);
    break;
  }

  _file->Close ();
}

template<class T, int DP, int DV>
void IOManager::Write (DistFunctionList<T, DP, DV> &dfl, const SimulTime &stime,
		       const char *tag)
{
  if (dfl.GetNumDFs () < 1)
    return;

  String fname = GetFileName (tag, stime);

  int driver = _file->GetDriver ();

  _file->SetSeparate ();
  _file->Open (fname, IOFile::suff);

  switch (_format)
  {
  case IO_FORMAT_XDMF:
  case IO_FORMAT_HDF5:
    dfl.Write (*((HDF5File*)_file), tag);
    break;
  }

  _file->Close ();
  _file->SetDriver (driver);
}
