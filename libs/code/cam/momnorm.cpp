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
  Domain<D> dom;
  dn.GetDomain (dom);
  DomainIterator<D> it (dom);

  T dni;
  while (it.HasNext ())
  {
    dni = dn(it.GetLoc ());

    if (dni < _dnmin)
    {
      blk(it.GetLoc ()) = FldVector (0.);
    }
    else
    {
      dni = 1./ dni;
      blk(it.GetLoc ()) *= dni;
    }

    it.Next ();
  }
}
