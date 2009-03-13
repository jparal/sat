/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   calcb.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::CalcB (T dt, VecField &Ba)
{
  Domain<D> dom;
  Ba.GetDomain (dom);
  DomainIterator<D> itb (dom);
  _E.GetDomainAll (dom);
  dom.HiAdd (-1);
  DomainIterator<D> ite (dom);

  FldVector curle;
  while (itb.HasNext ())
  {
    if_pt (!static_cast<B*>(this)->BcalcAdd (itb))
    {
      CartStencil::Curl (_E, ite, curle);
      curle *= (T)dt;
      Ba (itb.GetLoc ()) -= curle;
    }
    itb.Next ();
    ite.Next ();
  }
}
