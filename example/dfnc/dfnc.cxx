/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   dfnc.cxx
 * @brief  Store Z plasma dispersion function.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"

#define FILE_NAME "output"

typedef Vector<float,2> VVector;
typedef Vector<float,2> PVector;
typedef Vector<int,2> IVector;

int main (int argc, char **argv)
{
  Mpi::Initialize (&argc, &argv);

  Vector<int,2> ncell (6, 6);
  Vector<float,2> vmin (0, 0);
  Vector<float,2> vmax (3, 3);

  DistFunctionList<float,2, 2> dfl;
  dfl.Initialize (ncell, vmin, vmax);

  dfl.AddDF (IVector (0, 2), IVector (100, 10*Mpi::Rank ()));
  dfl.AddDF (IVector (1, 2), IVector (100, 10*Mpi::Rank ()));
  dfl.AddDF (IVector (1, 3), IVector (100, 10*Mpi::Rank ()));

  dfl.Update (PVector (1.1, 3.1), VVector (0.0, 0.0));
  dfl.Update (PVector (0.1, 2.1), VVector (2.9, 2.9));
  dfl.Update (PVector (1.1, 2.1), VVector (2.0, -2.));

  IOManager iom;
  SimulTime stime;
  ConfigFile cfg;
  stime.Initialize (1, 2);
  cfg.ReadFile ("dfnc.sin");
  cfg.SetAutoConvert ();

  iom.Initialize (cfg);
  iom.Write (dfl, stime, "DF");

  Mpi::Finalize ();
}
