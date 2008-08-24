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
  Domain<D> dom;
  fld.GetDomain (dom);
  DomainIterator<D> it (dom);

  Vector<int,D> loc;
  T2 avg;
  const double inv = MetaInv<4*D>::Is;
  while (it.HasNext ())
  {
    loc = it.GetLoc ();

    avg = fld(loc) * 0.5;
    for (int i=0; i<D; ++i)
    {
      loc[i] -= 1;
      avg += inv * fld (loc);
      loc[i] += 2;
      avg += inv * fld (loc);
      loc[i] -= 1;
    }
    fld(loc) = avg;

    it.Next ();
  }
}
