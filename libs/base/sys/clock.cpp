/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   clock.cpp
 * @brief  Wrapper around time measurements.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 * @reventry{2007/08, @jparal}
 * @revmessg{Remove calling of MPI and use gettimeofday function}
 */

#include "clock.h"
#include "inline.h"

/*
*************************************************************************
* Initialize clock.                                                     *
*************************************************************************
*/
SAT_INLINE
void Clock::Initialize (clock_t& clock)
{
  clock = times (&s_tmsbuff);
}

SAT_INLINE
void Clock::Initialize (double& clock)
{
   clock = 0.;
}

/*
*************************************************************************
* Timestamp the provided structures with current system clock readings. *
*************************************************************************
*/
SAT_INLINE
void Clock::Timestamp (clock_t& user, clock_t& sys, clock_t& wall)
{
  wall = times (&s_tmsbuff);
  sys  = s_tmsbuff.tms_stime;
  user = s_tmsbuff.tms_utime;
}

SAT_INLINE
void Clock::Timestamp (clock_t& user, clock_t& sys, double& wall)
{
  s_nullclock = times (&s_tmsbuff);

  struct timeval tv;
  gettimeofday(&tv, NULL);
  wall = tv.tv_sec;
  wall += (double)tv.tv_usec / 1000000.0;

  sys  = s_tmsbuff.tms_stime;
  user = s_tmsbuff.tms_utime;
}

/*
*************************************************************************
* Get the clock cycle used by the system (time is then computed         *
* as measured_time/clock_cycle)                                         *
*************************************************************************
*/
SAT_INLINE
double Clock::ClockCycle()
{
  return double(sysconf(_SC_CLK_TCK));
}
