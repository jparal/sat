/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   clock.h
 * @brief  System wrapper around processor clocks (i.e. function \c times )
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CLOCK_H__
#define __SAT_CLOCK_H__


/** @addtogroup base_sys
 *  @{
 */

#include "satconfig.h"
#include "stdhdrs.h"

/**
 * Class Clock serves as a single point of access for system clock information.
 * System and user time are computed via the POSIX compliant times() function.
 * This is described on p. 137, Lewine, POSIX programmers guide, 1992.  The
 * methods and structs used in this utility are defined in <sys/times.h>.
 * Start and end times are stored as variables of type clock_t.  A clock_t
 * value can be converted to seconds by dividing by CLK_TCK (which is defined
 * in <sys/times.h>).  Different systems may use different CLK_TCK.  Time is
 * accessed by calling the times() function which takes as an argument a
 * reference to an object of type struct tms.  This object will record the
 * system and user time (obj.tms_utime \& obj.tms_stime) and will return the
 * time since the system was started.
 *
 * The return value from the call to times() can be used to compute elapsed
 * wallclock time.  Alternatively, one can use MPI_Wtime() if MPI libraries are
 * included.  Two methods are defined for accessing system time - one that has
 * a clock_t struct argument for wallclock time (the non-MPI case) and one that
 * has a double argument to record the value of MPI_Wtime().
 *
 * Computing user/system/wallclock time with the times() function is performed
 * as follows:
 *
 * @code
 *    struct tms buffer;
 *    clock_t wtime_start = times(&buffer);
 *    clock_t stime_start = buffer.tms_stime;
 *    clock_t utime_start = buffer.tms_utime;
 *    // do some computational work
 *    clock_t wtime_stop  = times(&buffer);
 *    clock_t stime_stop  = buffer.tms_stime;
 *    clock_t utime_stop  = buffer.tms_utime;
 *    double wall_time   = double(wtime_stop-wtime_start)/double(CLK_TCK);
 *    double user_time   = double(utime_stop-utime_start)/double(CLK_TCK);
 *    double sys_time    = double(stime_stop-stime_start)/double(CLK_TCK);
 * @endcode
 *
 */
struct Clock
{
  /**
   * Initialize system clock.  Argument must be in the "clock_t" format which
   * is a standard POSIX struct provided on most systems in the <sys/times.h>
   * include file. On Microsoft systems, it is provided in <time.h>.
   */
  static void Initialize(clock_t& clock);

  /// Initialize system clock, where clock is in double format.
  static void Initialize(double& clock);

  /// Timestamp clocks for user, system, and wallclock times.
  static void Timestamp(clock_t& user, clock_t& sys, clock_t& wall);

  /**
   * Timestamp user, system, and walltime clocks.  Wallclock argument is in
   * double format since it will access wallclock times from MPI_Wtime()
   * function.
   */
  static void Timestamp(clock_t& user, clock_t& sys, double& wall);

  /// Returns clock cycle for the system.
  static double ClockCycle();

private:
  static struct tms s_tmsbuff;
  static clock_t s_nullclock;
};

#include "clock.cpp"

/** @} */

#endif /* __SAT_CLOCK_H__ */
