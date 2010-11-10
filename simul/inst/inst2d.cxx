/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   inst.cxx
 * @brief  Instability CAM simulation
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/11, @jparal}
 * @revmessg{Initial version}
 */

#include "inst.h"

int main (int argc, char **argv)
{
  InstabilityCAMCode<float,2> inst;
  inst.Initialize (&argc, &argv);
  inst.Exec ();

  return 0;
}
