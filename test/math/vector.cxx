/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   vector.cxx
 * @brief  Vector tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/01, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "satbase.h"
#include "math/misc/vector.h"

template<int D>
class Loc : public Vector<int,D>
{
public:
  Loc (int i0) : Vector<int,D>::Vector (i0) {};
  Loc (int i0, int i1) : Vector<int,D>::Vector (i0, i1) {};
  Loc (int i0, int i1, int i2) : Vector<int,D>::Vector (i0, i1, i2) {};
};

SUITE (VectorSuite)
{
  TEST (BaseTest)
  {
    Vector<float> v1;
    Loc<3> v (1);
    if (++v[0]>1)
      DBG_INFO (v.Desc ());

    Array<Vector<int,3> > arr;
    arr.SetSize (10);
    arr[0] = Vector<int,3> (1,2,3);
    DBG_INFO (arr[0][2]);
  }
}
