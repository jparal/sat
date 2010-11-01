/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   timer.cxx
 * @brief  Timer class to track elapsed time in portions of a program.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{21.03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "timer.h"

Timer::Timer(bool start)
{
  Reset ();

  if (start)
    Start ();
}

void Timer::Reset ()
{
  _walltime = 0.;
  _walltimeStart = 0.;
  _walltimeStop = 0.;
  _isrunning = false;
}

void Timer::Start()
{
  _isrunning = true;
  Clock::GetWallTime (_walltimeStart);
}

void Timer::Update ()
{
  if (_isrunning)
  {
    Clock::GetWallTime (_walltimeStop);
    _walltime += _walltimeStop - _walltimeStart;
    _walltimeStart = _walltimeStop;
  }
}

void Timer::Stop()
{
  if (_isrunning)
  {
    _isrunning = false;
    Clock::GetWallTime (_walltimeStop);
    _walltime += _walltimeStop - _walltimeStart;
  }
}
