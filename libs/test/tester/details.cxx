/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   details.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "details.h"

namespace SAT {
namespace Test {

TestDetails::TestDetails (char const* testName_,
			  char const* suiteName_,
			  char const* filename_,
			  int lineNumber_)
  : suiteName(suiteName_)
  , testName(testName_)
  , filename(filename_)
  , lineNumber(lineNumber_)
{
}

TestDetails::TestDetails (const TestDetails& details, int lineNumber_)
  : suiteName(details.suiteName)
  , testName(details.testName)
  , filename(details.filename)
  , lineNumber(lineNumber_)
{
}


} /* namespace Test */
} /* namespace SAT */
