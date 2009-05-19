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

/**
 * @todo Move this program into tools so we can actually convert values on the
 *       go.
 */
int main (int argc, char **argv)
{
  SIHybridUnitsConvert<float> si2h;
  float b0 = 21; // [nT]
  float n0 = 32; // [cm^-3]
  si2h.Initialize (b0, n0);

  bool inv;
  inv = true; // hybrid => SI
  inv = false; // SI => hybrid
  DBG_INFO ("Time [1 s]:      "<<si2h.Time (1, inv));
  DBG_INFO ("Length [1 m]:    "<<si2h.Length (1, inv));
  DBG_INFO ("Speed [1 m/s]:   "<<si2h.Speed (1, inv));
  DBG_INFO ("Accel [1 m/s^2]: "<<si2h.Accel (1, inv));

  DBG_LINE ("Examples");
  DBG_INFO ("Speed of 1 eV Na pcle: "<<
	    si2h.Speed (Math::Sqrt((4.*2.*1.6e-19)/(29.9*1.67e-27)))<<" [v_A]");
}
