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
  Omp::Initialize ();

  Solver sol;
  sol.Initialize (argc, argv);
  sol.Print ();
  sol.SolveAll ();

  return 0;
}
