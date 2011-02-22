/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdflist.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#include "rectdflist.h"
#include "rectdflist.cpp"

template class DistFunctionList<float, 1, 2>;
template class DistFunctionList<float, 1, 3>;
template class DistFunctionList<float, 2, 2>;
template class DistFunctionList<float, 2, 3>;
template class DistFunctionList<float, 3, 2>;
template class DistFunctionList<float, 3, 3>;

template class DistFunctionList<double, 1, 2>;
template class DistFunctionList<double, 1, 3>;
template class DistFunctionList<double, 2, 2>;
template class DistFunctionList<double, 2, 3>;
template class DistFunctionList<double, 3, 2>;
template class DistFunctionList<double, 3, 3>;
