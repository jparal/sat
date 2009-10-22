/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   testbase.h
 * @brief  Basic class of the test
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TESTBASE_H__
#define __SAT_TESTBASE_H__

/// @addtogroup test_tester
/// @{

#include "details.h"
#include "results.h"

namespace SAT {
namespace Test {

class TestResults;
class TestList;

/**
 * @brief Main class implementing Test itself
 */
class Test
{
public:
  Test (char const* testName, char const* suiteName = "DefaultSuite",
	char const* filename = "", int lineNumber = 0);

  virtual ~Test ();

  void Run (TestResults& testResults) const;

  TestDetails const m_details;
  Test* next;
  mutable bool m_timeConstraintExempt;

  static TestList& GetTestList ();

private:
  virtual void RunImpl (TestResults& testResults_) const;

  Test (Test const&);
  Test& operator= (Test const&);
};

} /* namespace Test */
} /* namespace SAT */

/// @}

#endif /* __SAT_TESTBASE_H__ */
