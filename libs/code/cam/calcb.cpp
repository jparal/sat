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

  T ld = 10.;
  FldVector curle, gradpsi;
  do
  {
    if_pt (!static_cast<B*>(this)->BcalcAdd (itb))
    {
      CartStencil::Curl (_E, ite, curle);
      //      CartStencil::Grad (psi, ite, gradpsi);

      // Mask advancing of B field with exponential function
      T mask = static_cast<B*>(this)->BmaskAdd (itb);
      for (int idim=0; idim<D; ++idim)
      {
        if (_layop.IsOpen (idim))
        {
	  T dx = _meshp.GetResol (idim);
          T npx = _B.GetLayout().GetDecomp().GetSize (idim);
          T ipx = _B.GetLayout().GetDecomp().GetPosition (idim);
          T ncx = _B.Size(idim)-1;
          T llx = npx * ncx * dx;
          T ppx = (ipx * ncx + (T)itb.GetLoc(idim)) * dx;

          // left & right boundaries
          mask *= T(1) - Math::Exp (-ppx/ld);
          mask *= T(1) - Math::Exp (-(llx-ppx)/ld);
        }
      }

      curle *= dt * mask;
      //      gradpsi *= dt * mask;
      Ba (itb) -= curle;
      //      Ba (itb) += gradpsi;
    }
  }
  while (itb.Next() && ite.Next());
}
