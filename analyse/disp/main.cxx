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

int main (int argc, char **argv)
{
  ConfigDisp cfg;
  cfg.Initialize (argc, argv);

  // Array<double> arr;
  // for (int i=0; i<10000; ++i)
  //   arr.Push ((double)i+0.5);
  // HDF5File file;
  // file.Write (arr, "Test", "pokus");

  return 0;
}
