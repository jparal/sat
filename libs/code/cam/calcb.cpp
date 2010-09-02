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
  Domain<D> dom;
  Ba.GetDomain (dom);
  DomainIterator<D> itb (dom);
  _E.GetDomainAll (dom);
  dom.HiAdd (-1);
  DomainIterator<D> ite (dom);

  T r = 1., ld = 10.;
  const T dx = _meshp.GetResol (0);
  FldVector curle, gradpsi;
  do
  {
    if_pt (!static_cast<B*>(this)->BcalcAdd (itb))
    {
      CartStencil::Curl (_E, ite, curle);
      //      CartStencil::Grad (psi, ite, gradpsi);

      /**
       * Mask advancing of B field with exponential instead of parabola
       */
      // Along the X-axis
      T fmu = 1., fmb = 1.;
      if (_layop.IsOpen (0))
      {
	T npx = _B.GetLayout().GetDecomp().GetSize (0);
	T ipx = _B.GetLayout().GetDecomp().GetPosition (0);
	T ncx = _B.Size(0)-1;
	T llx = npx * ncx * dx;
	T ppx = (ipx * ncx + (T)itb.GetLoc(0)) * dx;

	fmb = (T)1. - Math::Exp (-(llx-ppx)/ld);
      }
      // User supplied masking parameter
      fmu = static_cast<B*>(this)->BmaskAdd (itb);

      curle *= (T)dt * (fmu < fmb ? fmu : fmb);
      //      gradpsi *= (T)dt * (fmu < fmb ? fmu : fmb);
      Ba (itb) -= curle;
      //      Ba (itb) += gradpsi;
    }
  }
  while (itb.Next() && ite.Next());
}
