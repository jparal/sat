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
    printf ("  --vth NUM   thermal velocity of protons in vA\n");
    printf ("  --vsw NUM   solar wind velocity in vA\n");
    printf ("  --rad NUM   radius of planet in Lin\n");
    printf ("\n");
    printf ("  --vkms NUM  Solar wind speed in km/s\n");
    printf ("  --tpev NUM  Solar wind temperature in eV\n");
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

  double scale, tpev, vkms;
  bool enScale = false, enTpev = false, enVkms = false;
  DBG_INFO ("======= [ Misc ] ========");
  for (int iarg=3; iarg<argc; ++iarg)
  {
    if (!strcmp (argv[iarg], "--vth"))
    {
      double vthp = si2h.Speed (strtod (argv[++iarg], NULL), true);
      DBG_INFO ("T_proton  = "<< vthp*vthp * 1.0440e-08 <<" eV");
    }

    if (!strcmp (argv[iarg], "--vsw"))
    {
      double vsw = si2h.Speed (strtod(argv[++iarg], NULL), true);
      DBG_INFO ("Pdyn      = "<< n0*1e6*M_PHYS_MP*vsw*vsw*1e9 <<" nPa");
      DBG_INFO ("v_sw      = "<< vsw*1e-3 <<" km/s");
    }

    if (!strcmp (argv[iarg], "--rad"))
    {
      double rad = si2h.Length (strtod(argv[++iarg], NULL), true);
      DBG_INFO ("R_planet  = "<< rad*1e-3 <<" km");
    }

    if (!strcmp (argv[iarg], "--scale"))
    {
      scale = strtod(argv[++iarg], NULL);
      enScale = true;
    }

    if (!strcmp (argv[iarg], "--tpev"))
    {
      tpev = strtod(argv[++iarg], NULL);
      enTpev = true;
    }

    if (!strcmp (argv[iarg], "--vkms"))
    {
      vkms = strtod(argv[++iarg], NULL);
      enVkms = true;
    }

  }

  DBG_INFO ("======= [ Mercury ] ========");
  double radius = si2h.Length (M_PHYS_MERCURY_RADIUS*1e3, false);
  if (enScale) radius /= scale;
  double r3 = radius*radius*radius;
  DBG_INFO ("Radius   = " << radius << " Lin");
  DBG_INFO ("Dip Mom  = "<<250./b0 * r3);

  if (enTpev)
    DBG_INFO ("vth      = " << si2h.Speed (sqrt(tpev/1.0440e-08), false) <<" vA");
  if (enVkms)
    DBG_INFO ("vsw      = " << si2h.Speed (vkms * 1e3, false) <<" vA");
}
