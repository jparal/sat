/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   simtime.h
 * @brief  Simulation time.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/02, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SIMTIME_H__
#define __SAT_SIMTIME_H__

#include "base/sys/porttypes.h"
#include "base/sys/satver.h"
#include "base/common/refcount.h"
#include "base/satcfgfile.h"

/// @addtogroup simul_misc
/// @{

typedef uint32_t iter_t;

/**
 * @brief Simulation time class which keep track of current iteration related
 *        information.
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 * @reventry{2009/03, @jparal}
 * @revmessg{change simul.max into simul.tmax SIN variable}
 */
class SimulTime : public RefCount
{
public:
  /// Constructor
  SimulTime ();

  /**
   * Initialize simulation time class.
   *
   * @param dt time step
   * @param tmax maximal time of simulatio
   * @param restart restart simulation? If no then ignore tbeg parameter
   * @param tbeg time begin of simulation
   */
  void Initialize (double dt, double tmax,
		   bool restart = false, double tbeg = -1.);

  /**
   * Initialize simulation time from ConfigEntry class
   * @version @b 1.0
   * @code
   * simul:
   * {
   *   step    = 0.0025;
   *   tmax    = 1000.;
   *   start   = 0.;
   *   restart = false;
   * };
   * @endcode
   *
   * @param cfg configuration file entry
   * @param ver version of configure file (for backward compatibility)
   */
  void Initialize (ConfigEntry &cfg, satversion_t ver);
  void Initialize (ConfigFile &cfg, satversion_t ver);

  void Print () const;

  /**
   * Increment iteration and update time
   *
   * @return true if we should do next iteration, false otherwise
   */
  bool Next ();
  /// has next iteration
  bool HasNext () const;
  /// Return time step
  double Dt () const
  { return _dt; }
  /// return current time of simulation
  double Time () const
  { return _time; }
  /// return current iteration of simulation
  iter_t Iter () const
  { return _iter; }

  bool IsLastHyb () const
  { return _iter == _itout; }

  bool IsBeforeLastHyb () const
  { return _iter == _itout-1; }

  void IterStr (char *buff, int size, bool fill = false) const;

  /// return maximum number iteration we have to achieve
  iter_t ItersMax () const
  { return _maxiter; }
  /// return number of iteration left
  iter_t ItersLeft () const
  { return _maxiter-_iter; }
  /// are we restarting the simulation?
  bool Restart () const
  { return _restart; }

  void SetMilestone (iter_t niter);

private:
  bool _restart;
  double _dt;
  double _time;
  double _tmax;
  iter_t _iter;
  iter_t _itout;
  iter_t _maxiter;
};

/// @}

#endif /* __SAT_SIMTIME_H__ */
