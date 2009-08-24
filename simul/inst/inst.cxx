/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   ioncyclo.cxx
 * @brief  Ioncyclo wave CAM-CL simulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "inst.h"

int main (int argc, char **argv)
{
  IoncycloCAMCode<float,1> ioncyclo;
  ioncyclo.Initialize (&argc, &argv);
  ioncyclo.Exec ();

  return 0;
}
