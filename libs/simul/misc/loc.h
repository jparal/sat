/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   loc.h
 * @brief  Index/Location fo Field representation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_LOC_H__
#define __SAT_LOC_H__

#include "satmath.h"

/// @addtogroup simul_misc
/// @{

/**
 * @brief Index/Location fo Field representation
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<int D>
class Loc : public Vector<int,D>
{
public:
  Loc () : Vector<int,D> (0) {};
  Loc (int i0) : Vector<int,D> (i0) {};
  Loc (int i0, int i1) : Vector<int,D> (i0, i1) {};
  Loc (int i0, int i1, int i2) : Vector<int,D> (i0, i1, i2) {};
};

/// @}

#endif /* __SAT_LOC_H__ */
