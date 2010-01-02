/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wave.cxx
 * @brief  Wave CAM-CL simulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @revision{1.1}
 * @reventry{2009/12, @jparal}
 * @revmessg{Rename from alfven to wave}
 */

#include "wave.h"

int main (int argc, char **argv)
{
  WaveCAMCode<float,1> wave;
  wave.Initialize (&argc, &argv);
  wave.Exec ();

  return 0;
}
