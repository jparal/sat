/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   exec.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::Exec ()
{
  MomInit ();
  CalcE (_B, _Ua, _dn, true);

  do
  {
    _sensmng.SaveAll (_time);
    _sensmng.SetNextOutput (_time);

    Hyb ();
  }
  while (_time.Iter () < _time.ItersMax ());

  _sensmng.SaveAll (_time);
  _sensmng.SetNextOutput (_time);
}
