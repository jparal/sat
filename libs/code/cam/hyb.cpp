/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hyb.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

extern "C" void trace_start(void);
extern "C" void trace_stop(void);
extern "C" void vmon_begin(void);
extern "C" void vmon_done(void);
#define TRACED_ITER 5000

template<class B, class T, int D>
void CAMCode<B,T,D>::Hyb ()
{
  T dt = _time.Dt ();

  First ();
  AdvField ((T)0.5 * dt);

  /// BG/P Profiling
  // vmon_begin();

  while (_time.Next ())
  {
    /// BG/P MPI Tracing
    // if (_time.Iter () == TRACED_ITER)
    //   trace_start();

    static_cast<B*>(this)->PreMove ();

    AdvMom ();
    Move ();

    // we handle first half-step and the last half-step separately
    if (_time.IsBeforeLastHyb ())
    {
      _time.Next ();
      break;
    }

    AdvField (dt);

    /// BG/P MPI Tracing
    // if (_time.Iter () == TRACED_ITER)
    //   trace_stop();
  }

  /// BG/P Profiling
  // vmon_done();

  AdvField ((T)0.5 * dt);
  Last ();
}
