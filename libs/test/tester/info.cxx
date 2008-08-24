/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   info.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include <cstdlib>

#include "info.h"

namespace SAT {
namespace Test {

DeferredTestResult::DeferredTestResult()
  : suiteName(NULL)
  , testName(NULL)
  , failureFile(NULL)
  , failureMessage(NULL)
  , failureLine(0)
  , timeElapsed(0.0f)
  , failed(false)
{
}

DeferredTestResult::DeferredTestResult (char const* suite, char const* test)
  : suiteName(suite)
  , testName(test)
  , failureFile(NULL)
  , failureMessage(NULL)
  , failureLine(0)
  , timeElapsed(0.0f)
  , failed(false)
{
}

} /* namespace Test */
} /* namespace SAT */
