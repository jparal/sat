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
  char buff[24];
  char fname[64];

  stime.IterStr (buff, 24, false);

  if (_dir.IsEmpty ())
  {
    snprintf (fname, 64, "%s%si%s", tag, _runname.GetData (), buff);
  }
  else
  {
    IO::Mkdir (_dir);
    snprintf (fname, 64, "%s/%s%si%s", _dir.GetData (), tag,
	      _runname.GetData (), buff);
  }

  switch (_format)
  {
  case IO_FORMAT_STW:
    DBG_WARN ("");
  case IO_FORMAT_XDMF:
    // write XDMF
  case IO_FORMAT_HDF5:
    _hdf5.Write (fld, Cell, tag, fname);
    break;
  }
}
