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
  _timer.Start ();

  MomInit ();
  CalcE (_B, _Ua, _dn, true);

  Timer thyb;
  do
  {
    _sensmng.SaveAll (_time);
    _sensmng.SetNextOutput (_time);

    DBG_INFO ("iteration time : "<<thyb);
    _timer.Update ();
    DBG_INFO ("wallclock time : "<<_timer);

    thyb.Reset ();
    thyb.Start ();
    int nit = _time.HybIters () -_time.Iter ();

    Hyb ();

    thyb.Stop ();
    thyb /= nit;

    if (Mpi::Rank () == 0)
    {
      _itertime.Push (thyb.GetWallclockTime ());

      String fname = _sensmng.GetIOManager().GetFileName ("Stat");
      HDF5File file (fname, IOFile::suff);
      file.Write (_itertime, "Iter");
    }
  }
  while (_time.Iter () < _time.ItersMax ());

  _sensmng.SaveAll (_time);
  _sensmng.SetNextOutput (_time);
}
