/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   psd.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "psd.h"
#include "base/sys/assert.h"

#define SDF_XLEFT  0.
#define SDF_XRIGHT 10.

PSDRandGen::PSDRandGen ()
  : _initialized(false) {}

void PSDRandGen::Initialize (double bind, double xpar)
{
  _u = bind;
  _xpar = xpar;

  _cnorm = 10.*_xpar*(1+_xpar)*Math::Pow(_u,xpar);

  _2pxp = 2.+_xpar;
  _initialized = true;
  TBase::Initialize (SDF_XLEFT, SDF_XRIGHT, true);
}

double PSDRandGen::EvalDF (double x)
{
  SAT_DBG_ASSERT (_initialized);

  return _cnorm * x / Math::Pow(x+_u,_2pxp);
}
