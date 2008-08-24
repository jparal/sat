/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   check.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include <string.h>
#include "checks.h"

namespace SAT {
namespace Test {

namespace {

void CheckStringsEqual (TestResults& results,
			char const* const expected,
			char const* const actual,
			TestDetails const& details)
{
  if (strcmp(expected, actual))
  {
    String s;
    s << "Expected " << expected << " but was " << actual;

    results.OnTestFailure(details, s);
  }
}

}


void CheckEqual (TestResults& results,
		 char const* const expected,
		 char const* const actual,
		 TestDetails const& details)
{
  CheckStringsEqual (results, expected, actual, details);
}
  
void CheckEqual (TestResults& results,
		 char* const expected,
		 char* const actual,
		 TestDetails const& details)
{
  CheckStringsEqual (results, expected, actual, details);
}

void CheckEqual (TestResults& results,
		 char* const expected,
		 char const* const actual,
		 TestDetails const& details)
{
  CheckStringsEqual (results, expected, actual, details);
}

void CheckEqual (TestResults& results,
		 char const* const expected,
		 char* const actual,
		 TestDetails const& details)
{
  CheckStringsEqual(results, expected, actual, details);
}

} /* namespace Test */
} /* namespace SAT */
