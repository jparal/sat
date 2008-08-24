/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repdeferred.h
 * @brief  Deffered test reporter
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REPDEFERRED_H__
#define __SAT_REPDEFERRED_H__

#include "reporter.h"
#include "info.h"

#include "newdisable.h"
#include <vector>
#include "newenable.h"

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

/**
 * \brief Individual reporter for each test
 */
class DeferredTestReporter : public TestReporter
{
public:
  virtual void ReportTestStart (TestDetails const& details);

  virtual void ReportFailure (TestDetails const& details,
			      char const* failure);

  virtual void ReportTestFinish (TestDetails const& details,
				 float secondsElapsed);

  typedef std::vector< DeferredTestResult > DeferredTestResultList;
  DeferredTestResultList& GetResults();

private:
  DeferredTestResultList m_results;
};

} /* namespace Test */
} /* namespace SAT */


/** @} */

#endif /* __SAT_REPDEFERRED_H__ */
