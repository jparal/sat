/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   results.h
 * @brief  Desriptive class about test results
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RESULTS_H__
#define __SAT_RESULTS_H__

/// @addtogroup test_tester
/// @{

namespace SAT {
namespace Test {

class TestReporter;
class TestDetails;

/**
 * @brief Class representing results of the tests
 */
class TestResults
{
public:
    explicit TestResults (TestReporter* reporter = 0);

    void OnTestStart (TestDetails const& test);
    void OnTestFailure (TestDetails const& test, char const* failure);
    void OnTestFinish (TestDetails const& test, float secondsElapsed);

    int GetTotalTestCount () const;
    int GetFailedTestCount () const;
    int GetFailureCount () const;

private:
    TestReporter* m_testReporter;
    int m_totalTestCount;
    int m_failedTestCount;
    int m_failureCount;

    bool m_currentTestFailed;

    TestResults (TestResults const&);
    TestResults& operator= (TestResults const&);
};

} /* namespace Test */
} /* namespace SAT */

/// @}

#endif /* __SAT_RESULTS_H__ */
