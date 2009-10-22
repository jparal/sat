/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   timer.h
 * @brief  Timer class to track elapsed time in portions of a program.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TIMER_H__
#define __SAT_TIMER_H__

#include "string.h"
#include "tau.h"

/// @addtogroup base_common
/// @{

/**
 * Class Timer holds the exclusive and total start, stop, and elapsed time for
 * timers instrumented in SAMRAI.  Total time is simply the time between calls
 * to the start() and stop() functions.  Exclusive time is applicable if there
 * are nested timers called.
 *
 * System and user start and end times are stored as variables of type clock_t,
 * defined in the sys/times.h include file.  A detailed explanation of the
 * structures used to store system and user times is given in the header for
 * the Clock class. This routine simply accesses the functions specified in
 * that class.
 *
 * Wallclock time may be computed by the systems internal clocks which require
 * an object of type clock_t, or by MPI_Wtime() if the code is linked to MPI
 * libraries.
 *
 * In addition to running or not running, a timer may be active or inactive.
 * An inactive timer is one that is created within a program but will never be
 * turned on or off because it is either not specified as active in an input
 * file or it was not explicitly made active by the user.  When a timer is
 * created, it is active by default.
 *
 * Note that the constructor is protected so that timer objects can only be
 * created by the TimerManager class.
 *
 * @see TimerManager
 */
class TimerManager;

class Timer // : public DescribedClass
{
  friend class TimerManager;
public:
  /**
   * The constructor for the Timer class sets timer name string and integer
   * identifiers, and initializes the timer state.
   */
  Timer (const String& name, const int id = -1);

  /// Empty virtual destructor for Timer class.
  virtual ~Timer ();

  /// Return string name for timer.
  const String &GetName () const;

  /// Return integer identfier for timer.
  int GetIdentifier () const;

  /// Start the timer if active.
  void Start ();

  /// Stop the timer if active.
  void Stop ();

  /// Start exclusive time.
  void StartExclusive ();

  /// Stop exclusive time.
  void StopExclusive ();

  /// Reset the state of the timing information.
  void Reset ();

  /// Return total system time (between starts and stops)
  double GetTotalSystemTime () const;

  /// Return total user time
  double GetTotalUserTime () const;

  /// Return sum of user and system times.
  double GetTotalTime() const;

  /// Return total wallclock time
  double GetTotalWallclockTime () const;

  /// Return max wallclock time
  double GetMaxWallclockTime () const;

  /// Return exclusive system time.
  double GetExclusiveSystemTime () const;

  /// Return exclusive user time.
  double GetExclusiveUserTime () const;

  /// Return exclusive wallclock time.
  double GetExclusiveWallclockTime () const;

  /// Return true if the timer is active; false otherwise.
  bool IsActive () const;

  /// Return true if timer is running; false otherwise.
  bool IsRunning () const;

  /// Mark given integer as id of timer running concurrently with this one.
  void SetConcurrentTimer (const int id);

  /// Return the concurrent timer vector.
  bool* GetConcurrentTimerVector () const;

  /// Return number of accesses to start()-stop() functions for the timer.
  int GetNumberAccesses () const;

  /// Compute load balance efficiency based on wallclock (non-exclusive) time.
//   double LoadBalanceEfficiency ();

  /// Compute max wallclock time based on total (non-exclusive) time.
//   void MaxWallclock ();

  /// Write timer data members to database.
//   virtual void putToDatabase ( Pointer<Database> db );

  /**
   * Read restarted times from restart database.  When assertion checking is
   * on, the database pointer must be non-null.
   */
//   virtual void getFromRestart (Pointer<Database> db);

protected:
  /**
   * Set this timer object to be a inactive.  A timer is set inactive if it is
   * encountered in the code but it will not be turned on or off during program
   * execution.  See TimerManager for more information.
   */
  void SetInactive ();

private:
  /*
   * Class name, id, and concurrent timer flag.
   */
  String m_name;
  int m_identifier;
  bool* m_concurrent_timers;

  bool m_is_running;
  bool m_is_active;

  /*
   *  Total times (non-exclusive)
   */
  double m_user_total;
  double m_system_total;
  double m_wallclock_total;

  /*
   *  Exclusive times
   */
  double m_user_exclusive;
  double m_system_exclusive;
  double m_wallclock_exclusive;

  /*
   *  Cross processor times (i.e. determined across processors)
   */
  double m_max_wallclock;

  /*
   *  Timestamps.  User and system times are stored as type clock_t.
   *  Wallclock time is also stored as clock_t unless the library has
   * been compiled with MPI.  In this case, the wall time is stored
   * as type double.
   */
  clock_t m_user_start_total;
  clock_t m_user_stop_total;
  clock_t m_system_start_total;
  clock_t m_system_stop_total;
  clock_t m_user_start_exclusive;
  clock_t m_user_stop_exclusive;
  clock_t m_system_start_exclusive;
  clock_t m_system_stop_exclusive;
#ifndef HAVE_MPI
  clock_t m_wallclock_start_total;
  clock_t m_wallclock_stop_total;
  clock_t m_wallclock_start_exclusive;
  clock_t m_wallclock_stop_exclusive;
#else
  double m_wallclock_start_total;
  double m_wallclock_stop_total;
  double m_wallclock_start_exclusive;
  double m_wallclock_stop_exclusive;
#endif

  /*
   * Counter of number of times timers start/stop
   * are accessed.
   */
  int m_accesses;

  /*
   * Objects used for performance analysis with TAU.  The "tautimer" mapping
   * object is a tau timer that is associated with this SAMRAI timer.
   */
  TAU_MAPPING_OBJECT(tautimer)
};

#include "timer.cpp"

/// @}

#endif /* __SAT_TIMER_H__ */
