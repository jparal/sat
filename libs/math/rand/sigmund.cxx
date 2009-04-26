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

#define SDF_XLEFT  0.
#define SDF_XRIGHT 100.

SigmunRandGen::SigmunRandGen ()
  : _initialized(false) {}

void SigmunRandGen::Initialize (double bind, double trans)
{
  _bind = bind;
  _trans= trans;

  // set up the normalization constant so the max of the distribution is big
  // enough so ARMS can catch the function
  const double bp1 = bind + (double)1;
  _cnorm = 100.*(bp1*bp1*bp1)/((double)1-Math::Sqrt(bp1/trans));

  _initialized = true;
  TBase::Initialize (SDF_XLEFT, SDF_XRIGHT, true);
}

double SigmunRandGen::EvalDF (double x)
{
  SAT_DBG_ASSERT (_initialized);

  const double t = x + _bind;
  return _cnorm*x*((double)1-Math::Sqrt (t/_trans))/(t*t*t);
}
