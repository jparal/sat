/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   timer.cpp
 * @brief  Exclusive start and stop routines for timers.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "base/sys/clock.h"

/*
 ***************************************************************************
 *                                                                         *
 * Exclusive start and stop routines for timers.                           *
 *                                                                         *
 * For wallclock time: If we have MPI, we use MPI_Wtime to set the         *
 *                     start/stop point.  If we don't have MPI but do      *
 *                     have access to timer utilities in sys/times.h,      *
 *                     we use the time() utility to set the start/start    *
 *                     point.  If we have neither, we set the wallclock    *
 *                     start/stop time to zero.                            *
 *                                                                         *
 * For user time:      If we have access to timer utilities in sys/times.h,*
 *                     we use the times() utility to compute user and      *
 *                     system start/stop point (passing in the tms struct).*
 *                     If we don't have these utilities, we simply set the *
 *                     user and start/stop times to zero.                  *
 *                                                                         *
 * The timer manager manipulates the exclusive time information;  i.e.     *
 * when the timer's startExclusive and stopExclusive routines are called.  *
 *                                                                         *
 ***************************************************************************
 */

SAT_INLINE void Timer::StartExclusive ()
{
  if (m_is_active) {

    Clock::Timestamp(m_user_start_exclusive,
		     m_system_start_exclusive,
		     m_wallclock_start_exclusive);

  }
}

SAT_INLINE void Timer::StopExclusive ()
{
  if (m_is_active) {
    Clock::Timestamp(m_user_stop_exclusive,
		     m_system_stop_exclusive,
		     m_wallclock_stop_exclusive);

    m_wallclock_exclusive +=
      double(m_wallclock_stop_exclusive - m_wallclock_start_exclusive);
    m_user_exclusive +=
      double(m_user_stop_exclusive - m_user_start_exclusive);
    m_system_exclusive +=
      double(m_system_stop_exclusive - m_system_start_exclusive);
  }
}

/*
***************************************************************************
*                                                                         *
* Simple utility routines to manipulate timers.                           *
*                                                                         *
***************************************************************************
*/

SAT_INLINE const String &Timer::GetName() const
{
  return(m_name);
}

SAT_INLINE int Timer::GetIdentifier() const
{
  return(m_identifier);
}

SAT_INLINE bool Timer::IsActive() const
{
  return(m_is_active);
}

SAT_INLINE bool Timer::IsRunning() const
{
  return(m_is_running);
}

SAT_INLINE double Timer::GetTotalUserTime() const
{
  return(m_user_total/Clock::ClockCycle());
}

SAT_INLINE double Timer::GetTotalSystemTime() const
{
  return(m_system_total/Clock::ClockCycle());
}

SAT_INLINE double Timer::GetTotalTime() const
{
  return((m_user_total+m_system_total)/Clock::ClockCycle());
}

SAT_INLINE double Timer::GetTotalWallclockTime() const
{
// #ifndef HAVE_MPI
  double clock_cycle = Clock::ClockCycle();
// #else
//   double clock_cycle = 1.;
// #endif
  return(m_wallclock_total/clock_cycle);
}

SAT_INLINE double Timer::GetMaxWallclockTime() const
{
// #ifndef HAVE_MPI
  double clock_cycle = Clock::ClockCycle();
// #else
//   double clock_cycle = 1.;
// #endif
  return(m_max_wallclock/clock_cycle);
}

SAT_INLINE double Timer::GetExclusiveUserTime() const
{
  return(m_user_exclusive/Clock::ClockCycle());
}

SAT_INLINE double Timer::GetExclusiveSystemTime() const
{
  return(m_system_exclusive/Clock::ClockCycle());
}

SAT_INLINE double Timer::GetExclusiveWallclockTime() const
{
// #ifndef HAVE_MPI
  double clock_cycle = Clock::ClockCycle();
// #else
//   double clock_cycle = 1.;
// #endif
  return(m_wallclock_exclusive/clock_cycle);
}

SAT_INLINE void Timer::SetConcurrentTimer(const int id)
{
  m_concurrent_timers[id] = true;
}

SAT_INLINE bool* Timer::GetConcurrentTimerVector() const
{
  return(m_concurrent_timers);
}

SAT_INLINE int Timer::GetNumberAccesses() const
{
  return(m_accesses);
}

/*
***************************************************************************
*                                                                         *
* Private utility routines to manipulate timers in database.              *
*                                                                         *
***************************************************************************
*/

SAT_INLINE void Timer::SetInactive()
{
  m_is_active = false;
}
