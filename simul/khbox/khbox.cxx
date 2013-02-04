/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   khbox.cxx
 * @brief  Simulation of Kelvin-Helmholtz instability in 2D box.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2012/07, @jparal}
 * @revmessg{Initial version}
 */

#include "khbox.h"

int main (int argc, char **argv)
{
  SAT::EnableFPException();
  KHBoxCAMCode<float,2> khbox;
  khbox.Initialize (&argc, &argv);
  khbox.Exec ();

  return 0;
}
