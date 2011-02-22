/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   octreecell.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/01, @jparal}
 * @revmessg{Initial version}
 */

#include "octreecell.h"
#include "octreecell.cpp"

template class OctreeCell<float, 2>;
template class OctreeCell<float, 3>;

template class OctreeCell<double, 2>;
template class OctreeCell<double, 3>;
