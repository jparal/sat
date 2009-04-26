/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sigmund.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "sigmund.h"
#include "base/sys/assert.h"

SigmunRandGen::SigmunRandGen ()
  : _initialized(false) {}

void SigmunRandGen::Initialize (double bind, double trans)
{
  _bind = bind;
  _trans= trans;

  int dometrop = 1;
  double xleft = 0;
  double xright = 30;

  _initialized = true;
  TBase::Initialize (xleft, xright, dometrop);
}

double SigmunRandGen::EvalDF (double x)
{
  SAT_DBG_ASSERT (_initialized);

  const double cn = 3000./_bind;
  const double eeb = x+_bind;

  return (cn*x/(eeb*eeb*eeb)) * (1.-Math::Sqrt (eeb/_trans));
}
