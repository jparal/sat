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

  T r = 1., ld = 10.;
  const T dx = _meshp.GetResol (0);
  FldVector curle;
  do
  {
    if_pt (!static_cast<B*>(this)->BcalcAdd (itb))
    {
      CartStencil::Curl (_E, ite, curle);

      T fm = 1.;
      if (_layop.IsOpen (0) && _layop.GetDecomp ().IsLeftBnd (0))
      {
	if ((T)itb.GetLoc(0) * dx < ld)
	{
	  T pp = r*( (T)itb.GetLoc(0) * dx - ld )/ld;
	  fm = 1. - pp*pp;
	}
      }
      if (_layop.IsOpen (0) && _layop.GetDecomp ().IsRightBnd (0))
      {
	if ( (T)itb.GetLoc(0) * dx > (_pmax[0] - ld))
	{
	  T pp = r*( (T)itb.GetLoc(0) * dx - _pmax[0] + ld)/ld;
	  fm = 1. - pp*pp;
	}
      }

      curle *= (T)dt * fm;
      Ba (itb) -= curle;
    }
  }
  while (itb.Next() && ite.Next());
}
