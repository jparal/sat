/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   momnorm.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::MomNorm (const ScaField &dn, VecField &blk)
{
  DomainIterator<D> it;
  dn.GetDomainIterator (it, false);

  T dni;
  do
  {
    dni = dn(it);

    if (dni < _dnmin)
      blk(it) = FldVector (0.);
    else
      blk(it) /= dni;
  }
  while (it.Next());
}
