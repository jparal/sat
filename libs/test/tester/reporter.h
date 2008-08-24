/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   reporter.h
 * @brief  Abstract class for result test reporters
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REPORTER_H__
#define __SAT_REPORTER_H__

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

class TestDetails;

/**
 * \brief Base class for formating output.
 */
class TestReporter
{
public:
  virtual ~TestReporter () {};

  virtual void ReportTestStart (TestDetails const& test) = 0;

  virtual void ReportFailure (TestDetails const& test,
			      char const* failure) = 0;

  virtual void ReportTestFinish (TestDetails const& test,
				 float secondsElapsed) = 0;

  virtual void ReportSummary (int totalTestCount,
			      int failedTestCount,
			      int failureCount,
			      float secondsElapsed) = 0;
};

} /* namespace Test */
} /* namespace SAT */


/** @} */

#endif /* __SAT_REPORTER_H__ */
