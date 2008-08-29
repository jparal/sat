/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   domain.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "domain.h"

template<int D>
int Domain<D>::Length () const
{
  int len = 1;
  for (int i=0; i<D; ++i) len *= _range[i].Length ();
  return len;
}

template class Domain<1>;
template class Domain<2>;
template class Domain<3>;
template class Domain<4>;
template class Domain<5>;
template class Domain<6>;
