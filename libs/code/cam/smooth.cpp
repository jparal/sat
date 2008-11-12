/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   smooth.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
template<class T2, int D2>
void CAMCode<B,T,D>::Smooth (Field<T2,D2> &fld)
{
  Domain<D2> dom;
  fld.GetDomain (dom);
  DomainIterator<D2> it (dom);

  Vector<int,D2> loc;
  T2 avg, mid;
  const double inv = 0.25; //MetaInv<4*D2>::Is;

  for (int i=0; i<D2; ++i)
  {
    it.Reset ();
    loc = it.GetLoc ();
    loc[i] -= 1;
    mid = fld(loc);
    while (it.HasNext ())
    {
      loc = it.GetLoc ();

      avg = 0.25 * mid;
      mid = fld(loc);
      avg += 0.5 * mid;
      loc[i] += 1;
      avg += 0.25 * fld (loc);

      loc[i] -= 1;
      fld(loc) = avg;
      it.Next ();
    }
  }
}
