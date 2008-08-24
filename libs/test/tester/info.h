/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   info.h
 * @brief  Information about one test
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_INFO_H__
#define __SAT_INFO_H__

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

/**
 * \brief Structure holding results for each individual test
 */
struct DeferredTestResult
{
  DeferredTestResult();
  DeferredTestResult(char const* suite, char const* test);

  char const* suiteName;
  char const* testName;
  char const* failureFile;
  char const* failureMessage;
  int failureLine;
  float timeElapsed;
  bool failed;
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_INFO_H__ */
