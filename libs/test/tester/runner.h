/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   runner.h
 * @brief  Test runner
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RUNNER_H__
#define __SAT_RUNNER_H__

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

class TestReporter;
class TestList;


int RunAllTests (int argc, char **argv);
int RunAllTests (TestReporter   &reporter,
		 TestList const &list,
		 char const     *suiteName,
		 int             maxTestTimeInMs = 0);

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_RUNNER_H__ */
