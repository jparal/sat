/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   shock.cxx
 * @brief  Simulation of shock wave.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */

#include "shock.h"

int main (int argc, char **argv)
{
  SAT::EnableFPException();
  //  fedisableexcept (FE_ALL_EXCEPT);
  ShockCAMCode<float,2> sh;
  sh.Initialize (&argc, &argv);
  sh.Exec ();

  return 0;
}
