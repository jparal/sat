/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   meta.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "meta.h"

template<> const double MetaInv<1>::Is  = double(1./1.);
template<> const double MetaInv<2>::Is  = double(1./2.);
template<> const double MetaInv<4>::Is  = double(1./4.);
template<> const double MetaInv<8>::Is  = double(1./8.);
template<> const double MetaInv<12>::Is = double(1./12.);
