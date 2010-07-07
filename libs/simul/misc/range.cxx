/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   range.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "range.h"

void Range::Initialize ()
{
  _lo = _hi = 0;
}

void Range::Initialize (const Range &range)
{
  _lo = range._lo;
  _hi = range._hi;
}

void Range::Initialize (int i0)
{
  _lo = _hi = i0;
}

void Range::Initialize (int i0, int i1)
{
  _lo = i0;
  _hi = i0<=i1 ? i1 : i0;
}

