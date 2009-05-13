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

template<class B, class T, int D>
void CAMCode<B,T,D>::Hyb ()
{
  T dt = _time.Dt ();

  First ();
  AdvField ((T)0.5 * dt);

  while (_time.Next ())
  {
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
  }

  AdvField ((T)0.5 * dt);
  Last ();
}
