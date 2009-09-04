/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   main.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"
#include "cfgdisp.h"
#include "solver.h"

int main (int argc, char **argv)
{
  Solver sol;
  sol.Initialize (argc, argv);
  sol.Solve ();

  // Array<double> arr;
  // for (int i=0; i<10; ++i)
  //   arr.Push ((double)i+0.5);
  // HDF5File file;
  // file.Write (arr, "Test0", cfg.OutName ());
  // file.Write (arr, "Test1", cfg.OutName (), true);

  return 0;
}
