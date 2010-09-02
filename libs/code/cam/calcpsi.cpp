/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   calcpsi.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/08, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class B, class T, int D>
void CAMCode<B,T,D>::CalcPsi (T dt, const VecField &b, ScaField &psi)
{
  Domain<D> dom;
  b.GetDomain (dom);
  DomainIterator<D> itb (dom);
  psi.GetDomainAll (dom);
  dom.HiAdd (-1);
  DomainIterator<D> itp (dom);

  T divb, c2 = 5.*5.;
  do
  {
    CartStencil::Div (b, itb, divb);
    psi(itp) -= dt * (c2 * divb + psi(itp));
  }
  while (itb.Next() && itp.Next());
}
