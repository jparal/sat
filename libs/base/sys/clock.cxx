/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   clock.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "clock.h"

#include <stdlib.h>

void Clock::GetWallTime (double& wall)
{
  struct timeval tv;
  gettimeofday(&tv, NULL);
  wall = tv.tv_sec;
  wall += (double)tv.tv_usec / 1000000.0;
}

double Clock::ClockCycle()
{
  return double(sysconf(_SC_CLK_TCK));
}
