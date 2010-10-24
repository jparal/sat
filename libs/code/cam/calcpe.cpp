/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   calcpe.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B,class T, int D>
void CAMCode<B,T,D>::CalcPe (const ScaField &dn)
{
  Domain<D> dom;
  dn.GetDomain (dom);
  DomainIterator<D> itn (dom);

  do
  {
    _pe(itn) = _te * Math::Pow (dn (itn), _gamma);
  }
  while (itn.Next());
}
