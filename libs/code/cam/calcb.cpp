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
void CAMCode<B,T,D>::CalcB (T dt, const ScaField &psi, VecField &Ba)
{
  DomainIterator<D> itb, ite;
  Ba.GetDomainIterator (itb, false);
  _E.GetDomainIteratorAll (ite, true);

  T mask = T(1);
  FldVector curle, gradpsi;
  do
  {
    if_pt (!static_cast<B*>(this)->BcalcAdd (itb))
    {
      CartStencil::Curl (_E, ite, curle);
      //      CartStencil::Grad (psi, ite, gradpsi);

      mask *= MaskBC (itb);
      mask *= static_cast<B*>(this)->BmaskAdd (itb);

      curle *= dt * mask;
      //      gradpsi *= dt * mask;
      Ba (itb) -= curle;
      //      Ba (itb) += gradpsi;
    }
  }
  while (itb.Next() && ite.Next());
}
