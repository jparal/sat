/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repdeferred.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "repdeferred.h"
#include "details.h"

using namespace SAT::Test;

void DeferredTestReporter::ReportTestStart (TestDetails const& details)
{
  m_results.push_back(DeferredTestResult(details.suiteName, details.testName));
}

void DeferredTestReporter::ReportFailure (TestDetails const& details,
					  char const* failure)
{
  DeferredTestResult& r = m_results.back();
  r.failed = true;
  r.failureLine = details.lineNumber;
  r.failureFile = details.filename;
  r.failureMessage = failure;
}

void DeferredTestReporter::ReportTestFinish (TestDetails const&,
					     float const secondsElapsed)
{
  DeferredTestResult& r = m_results.back();
  r.timeElapsed = secondsElapsed;
}

DeferredTestReporter::DeferredTestResultList& DeferredTestReporter::GetResults()
{
  return m_results;
}
