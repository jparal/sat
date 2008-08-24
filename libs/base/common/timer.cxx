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

#ifndef TIMER_MAX_CONCURRENT_TIMERS
#define TIMER_MAX_CONCURRENT_TIMERS (128)
#endif

/*
*************************************************************************
* The constructor sets the timer name and initializes timer state.      *
*************************************************************************
*/
Timer::Timer(const String& name, const int id)
{
  m_name = name;
  m_identifier = id;
  m_is_running = false;
  m_is_active = true;
  m_accesses = 0;
  m_concurrent_timers = new bool[TIMER_MAX_CONCURRENT_TIMERS];

#ifdef HAVE_VAMPIR
  string::size_type position;

  // parse timers name down to method
  position = name.find("::");
  string class_method = name.substr(position+2);
  position = class_method.find("::");
  string class_name = class_method.substr(0,position);
  string method = class_method.substr(position+2);

  // convert strings to char* type
  char* char_method = new char[method.length()+1];
  method.copy(char_method,string::npos);
  char_method[method.length()] = 0;

  char* char_class = new char[class_name.length()+1];
  class_name.copy(char_class,string::npos);
  char_class[class_name.length()] = 0;

  VT_symdef(id,char_class,char_method);
#endif

  /// Create a Tau "timer" to track time.
  TAU_MAPPING_TIMER_CREATE (tautimer, name, " ", TAU_USER2, "SAMRAI_DEFAULT");

  Clock::Initialize (m_user_start_exclusive);
  Clock::Initialize (m_user_stop_exclusive);
  Clock::Initialize (m_system_start_exclusive);
  Clock::Initialize (m_system_stop_exclusive);
  Clock::Initialize (m_wallclock_start_exclusive);
  Clock::Initialize (m_wallclock_stop_exclusive);

  Reset();
}

Timer::~Timer()
{
  delete [] m_concurrent_timers;
}

/*
***************************************************************************
*                                                                         *
* Start and stop routines for timers.                                     *
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
* Note that the stop routine increments the elapsed time information.     *
* Also, the timer manager manipulates the exclusive time information      *
* the timers when start and stop are called.                              *
*                                                                         *
***************************************************************************
*/

void Timer::Start()
{
  m_accesses++;

  if (m_is_active) {

    Clock::Timestamp(m_user_start_total,
		     m_system_start_total,
		     m_wallclock_start_total);

    m_is_running = true;

#ifdef HAVE_VAMPIR
    VT_begin(m_identifier);
#endif

#ifdef HAVE_TAU
    /*
     * Start the TAU timer.  The "tid" is used for threaded systems
     * so it generally won't apply for us.  The profiler accesses
     * the timer (given the "tautimer" for this timer object) which
     * returns "t", and then starts "t".
     */
    int tid = RtsLayer::myThread();
    TAU_MAPPING_PROFILE_TIMER(t, tautimer, tid);
    TAU_MAPPING_PROFILE_START(t, tid);
#endif

    /// @@@TODO
    // TimerManager::getManager()->startTime(this);

  }
}
void Timer::Stop()
{
  if (m_is_active) {

    /// @@@TODO TimerManager::getManager()->stopTime(this);

#ifdef HAVE_VAMPIR
    VT_end(m_identifier);
#endif

#ifdef HAVE_TAU
    TAU_MAPPING_PROFILE_STOP(RtsLayer::myThread());
#endif

    Clock::Timestamp(m_user_stop_total,
		     m_system_stop_total,
		     m_wallclock_stop_total);

    m_is_running = false;

    m_wallclock_total +=
      double(m_wallclock_stop_total - m_wallclock_start_total);
    m_user_total += double(m_user_stop_total - m_user_start_total);
    m_system_total += double(m_system_stop_total - m_system_start_total);

  }

}

void Timer::Reset()
{
  m_user_total = 0.;
  m_system_total = 0.;
  m_wallclock_total = 0.;

  m_user_exclusive = 0.;
  m_system_exclusive = 0.;
  m_wallclock_exclusive = 0.;

  m_max_wallclock = 0.;

  for (int i = 0; i < TIMER_MAX_CONCURRENT_TIMERS; i++) {
    m_concurrent_timers[i] = false;
  }
}

/*
***************************************************************************
*                                                                         *
* Compute the load balance efficiency based the wallclock time on each    *
* processor, using the formula:                                           *
*                                                                         *
*      eff = (sum(time summed across processors)/#processors) /           *
*             max(time across all processors)                             *
*                                                                         *
* This formula corresponds to that used to compute load balance           *
* efficiency based on the processor distribution of the the number of     *
* cells (i.e. in BalanceUtilities::computeLoadBalanceEfficiency).         *
*                                                                         *
***************************************************************************
*/
// double Timer::LoadBalanceEfficiency()
// {
//   double sum = m_wallclock_total;

//   Mpi::SumReduce (&sum);

//   MaxWallclock();
//   int nprocs = Mpi::Nodes ();

//   double eff = 100.;
//   if (m_max_wallclock > 0.) {
//     eff = 100.*(sum/(double)nprocs)/m_max_wallclock;
//   }
//   return eff;
// }

// void Timer::MaxWallclock()
// {
//   double wall = m_wallclock_total;
//   Mpi::MaxReduce (&wall);
//   m_max_wallclock = wall;
// }

// void Timer::putToDatabase(
// 			  Pointer<Database> db)
// {
// #ifdef DEBUG_CHECK_ASSERTIONS
//   assert(!db.isNull());
// #endif
//   db->putInteger("TBOX_TIMER_VERSION",
// 		 TBOX_TIMER_VERSION);

//   db->putString("m_name",m_name);

//   db->putDouble("m_user_total",m_user_total);
//   db->putDouble("m_system_total", m_system_total);
//   db->putDouble("m_wallclock_total", m_wallclock_total);

//   db->putDouble("m_user_exclusive",m_user_exclusive);
//   db->putDouble("m_system_exclusive", m_system_exclusive);
//   db->putDouble("m_wallclock_exclusive", m_wallclock_exclusive);
// }

// void Timer::getFromRestart(
// 			   Pointer<Database> db)
// {
// #ifdef DEBUG_CHECK_ASSERTIONS
//   assert(!db.isNull());
// #endif
//   int ver = db->getInteger("TBOX_TIMER_VERSION");
//   if (ver != TBOX_TIMER_VERSION) {
//     TBOX_ERROR("Restart file version different than class version.");
//   }

//   m_name = db->getString("m_name");

//   m_user_total = db->getDouble("m_user_total");
//   m_system_total = db->getDouble("m_system_total");
//   m_wallclock_total = db->getDouble("m_wallclock_total");

//   m_user_exclusive = db->getDouble("m_user_exclusive");
//   m_system_exclusive = db->getDouble("m_system_exclusive");
//   m_wallclock_exclusive = db->getDouble("m_wallclock_exclusive");
// }
