/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   alfven.cxx
 * @brief  Alfven wave CAM-CL simulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "alfven.h"

int main (int argc, char **argv)
{
  AlfvenCAMCode<float,1> alfven;
  alfven.Initialize (&argc, &argv);
  alfven.Exec ();

  return 0;
}
