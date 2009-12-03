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
  case IO_FORMAT_HDF5:
    ((HDF5File*)_file)->Write (fld, tag);
    break;
  }

  _file->Close ();
}
