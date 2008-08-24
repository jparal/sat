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
  snprintf (fname, 64, "%s%si%s", tag, _runname.GetData (), buff);
  //  IO::Mkdir (fname);
  // snprintf (fname, 64, "%si%s/%s%si%s", _runname.c_str (), buff, tag,
  // 	    _runname.c_str (), buff);

  switch (_format)
  {
  case IO_FORMAT_XDMF:
    // Mpi::Barrier ();
    // DBG_INFO ("saving tag: "<<tag);
    _xdmf.Write (fld, Cell, tag, fname);
    break;
  }
}
