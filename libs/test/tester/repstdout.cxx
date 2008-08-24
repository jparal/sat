/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repstdout.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "stdio.h"

#include "repstdout.h"
#include "details.h"

namespace SAT {
namespace Test {

void TestReporterStdout::ReportFailure (TestDetails const& details,
					char const* failure)
{
#ifdef __APPLE__
  char const* const errorFormat = "%s:%d: error: Failure in %s: %s\n";
#else
  char const* const errorFormat = "%s(%d): error: Failure in %s: %s\n";
#endif
  printf(errorFormat,
	 details.filename, details.lineNumber, details.testName, failure);
}

void TestReporterStdout::ReportTestStart (TestDetails const& /*test*/)
{
}

void TestReporterStdout::ReportTestFinish (TestDetails const& /*test*/, float)
{
}

void TestReporterStdout::ReportSummary (int const totalTestCount,
					int const failedTestCount,
					int const failureCount,
					float secondsElapsed)
{
  if (failureCount > 0)
    printf("FAILURE: %d out of %d tests failed (%d failures).\n",
	   failedTestCount, totalTestCount, failureCount);
  else
    printf("Success: %d tests passed.\n", totalTestCount);

  printf("Test time: %.2f seconds.\n", secondsElapsed);
}

} /* namespace Test */
} /* namespace SAT */
