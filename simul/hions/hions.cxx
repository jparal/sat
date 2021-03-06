/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hions.cxx
 * @brief  Monte-Carlo simulation of heavy ions.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

int main (int argc, char **argv)
{
  SAT_CALLGRIND_STOP_INSTRUMENTATION;

  HeavyIonsCode<float> hions;
  hions.Initialize (&argc, &argv);

  SAT_CALLGRIND_START_INSTRUMENTATION;

  hions.Exec ();

  return 0;
}
