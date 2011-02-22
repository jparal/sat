/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdfcell.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#include "rectdfcell.h"
#include "rectdfcell.cpp"

template class RectDistFunction<float, 2>;
template class RectDistFunction<float, 3>;

template class RectDistFunction<double, 2>;
template class RectDistFunction<double, 3>;

