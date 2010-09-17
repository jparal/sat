/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   dipole.cxx
 * @brief  Simulation of magnetic dipole in solar wind.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/07, @jparal}
 * @revmessg{Initial version}
 */

#include "dipole.h"

int main (int argc, char **argv)
{
  SAT::EnableFPException();
  DipoleCAMCode<float,2> dip;
  dip.Initialize (&argc, &argv);
  dip.Exec ();

  return 0;
}
