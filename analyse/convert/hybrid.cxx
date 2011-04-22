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
  if (argc <= 2)
  {
    printf ("Usage: %s B0 n0 [optional arguments]\n\n", argv[0]);
    printf ("  B0 [nT]     is solar wind magnetic field\n");
    printf ("  n0 [cm^-3]  is solar wind particle density\n\n");
    printf (" Optional Arguments:\n");
    printf ("  --vthp NUM  thermal velocity of protons in vA\n");
    printf ("\n");
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
  DBG_INFO ("Mag. Field [nT]: "<< b0);
  DBG_INFO ("Density [cm^-3]: "<< n0);
  DBG_INFO ("======== [ SI to Hyb ] ========");
  DBG_INFO ("Time:    s     = "<< si2h.Time (1, false) << " Wp^-1");
  DBG_INFO ("Length:  m     = "<< si2h.Length (1, false) << " Lin");
  DBG_INFO ("Speed:   m/s   = "<< si2h.Speed (1, false) << " vA");
  DBG_INFO ("Accel:   m/s^2 = "<< si2h.Accel (1, false));
  DBG_INFO ("======= [ Hyb to SI ] ========");
  DBG_INFO ("Time:    1/Wp  = "<< si2h.Time (1, true) << " s");
  DBG_INFO ("Length:  Lin   = "<< si2h.Length (1, true) << " m");
  DBG_INFO ("Speed:   vA    = "<< si2h.Speed (1, true) << " m/s");
  DBG_INFO ("Accel:   Acc   = "<< si2h.Accel (1, true) << " m/s^2");
  DBG_INFO ("");

  for (int iarg=3; iarg<argc; ++iarg)
  {
    if (!strcmp (argv[iarg], "--vthp"))
    {
      double vthp = strtod (argv[++iarg], NULL) * si2h.Speed (1, true);
      DBG_INFO ("T_proton  = "<< vthp*vthp * 1.0440e-08 <<" eV");
    }
  }

}
