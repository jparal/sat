/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repstdout.h
 * @brief  Implementation of reporter writing to stdout
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REPSTDOUT_H__
#define __SAT_REPSTDOUT_H__


/** @addtogroup test_tester
 *  @{
 */

#include "reporter.h"

namespace SAT {
namespace Test {

/**
 * \brief Reporter of the test results into standart output
 */
class TestReporterStdout : public TestReporter
{
private:
  virtual void ReportTestStart (TestDetails const& test);
  virtual void ReportFailure (TestDetails const& test, char const* failure);
  virtual void ReportTestFinish (TestDetails const& test,
				 float secondsElapsed);
  virtual void ReportSummary (int totalTestCount,
			      int failedTestCount,
			      int failureCount,
			      float secondsElapsed);
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_REPSTDOUT_H__ */
