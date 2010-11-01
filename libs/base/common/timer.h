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
#include "base/sys/clock.h"

/// @addtogroup base_common
/// @{

class Timer
{
public:
  Timer (bool start = false);

  /// Empty virtual destructor for Timer class.
  virtual ~Timer () {};

  /// Start the timer if active.
  void Start ();

  /// Stop the timer if active.
  void Stop ();

  /// Update the timer if active.
  void Update ();

  /// Reset the state of the timing information.
  void Reset ();

  /// Return total wallclock time
  double GetWallclockTime ()
  { Update (); return _walltime; }

  /// Return true if timer is running; false otherwise.
  bool IsRunning () const
  { return _isrunning; }

  friend std::ostream& operator<< (std::ostream &os, Timer &time)
  {
    double sec = time.GetWallclockTime ();
    int days = int(sec / (60.*60.*24.));
    if (days > 0)
    {
      os << days << "d:";
      sec -= double(days * 60*60*24);
    }
    int hrs = int(sec / (60.*60.));
    if (hrs > 0)
    {
      os << hrs << "h:";
      sec -= double(hrs * 60*60);
    }
    int mins = int(sec / 60.);
    if (mins > 0)
    {
      os << mins << "m:";
      sec -= double(mins * 60);
    }

    int prec = os.precision(2);
    std::ios::fmtflags flags = os.flags ();

    os << std::fixed << sec << "s";

    os.precision(prec);
    os.flags (flags);
    return os;
  }

  Timer& operator/= (double v)
  {
    _walltime /= v;
    return *this;
  }

private:

  bool _isrunning;

  double _walltime;
  double _walltimeStart;
  double _walltimeStop;
};

/// @}

#endif /* __SAT_TIMER_H__ */
