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
  DomainIterator<D2> it;
  fld.GetDomainIterator (it, false);

  const T wgt = MetaInv<4*D2>::Is;
  Vector<int,D2> loc;

  Field<T2,D2> orig(fld);
  do
  {
    loc = it.GetLoc();
    T2 avg = (T)0.5 * orig(loc);
    for (int i=0; i<D2; ++i)
    {
      loc[i] -= 1;
      avg += wgt * orig(loc);
      loc[i] += 2;
      avg += wgt * orig(loc);
      loc[i] -= 1;
    }

    fld(loc) = avg;
  }
  while (it.Next());
}
