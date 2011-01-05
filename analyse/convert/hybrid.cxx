/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hybrid.cxx
 * @brief  Example of SI to hybrid units converter.
 * @author @jparal
 *
 * @revision{0.3.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"

int main (int argc, char **argv)
{
  if (argc != 3)
  {
    printf ("Usage: %s B0 n0\n\n", argv[0]);
    printf ("  B0 [nT]     is solar wind magnetic field\n");
    printf ("  n0 [cm^-3]  is solar wind particle density\n\n");
    exit (1);
  }

  float b0; // [nT]
  float n0; // [cm^-3]
  b0 = strtod (argv[1], NULL);
  n0 = strtod (argv[2], NULL);

  SIHybridUnitsConvert<float> si2h;
  si2h.Initialize (b0, n0);

  bool inv;
  inv = true; // hybrid => SI
  inv = false; // SI => hybrid
  DBG_INFO ("Mg. Field [nT]:  "<< b0);
  DBG_INFO ("Density [cm^-3]: "<< n0);
  DBG_INFO ("=======================================");
  DBG_INFO ("Time [1 s]:      "<< si2h.Time (1, inv));
  DBG_INFO ("Length [1 m]:    "<< si2h.Length (1, inv));
  DBG_INFO ("Speed [1 m/s]:   "<< si2h.Speed (1, inv));
  DBG_INFO ("Accel [1 m/s^2]: "<< si2h.Accel (1, inv));
}
