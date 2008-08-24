/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   testbase.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "base/common/string.h"

#include "testbase.h"
#include "testlist.h"
#include "exception.h"

namespace SAT {
namespace Test {

TestList& Test::GetTestList ()
{
  static TestList s_list;
  return s_list;
}

Test::Test (char const* testName, char const* suiteName,
	    char const* filename, int const lineNumber)
  : m_details(testName, suiteName, filename, lineNumber),
    next(0), m_timeConstraintExempt(false)
{}

Test::~Test ()
{}

void Test::Run (TestResults& testResults) const
{
  try
  {
#ifdef UNITTEST_POSIX
    UNITTEST_THROW_SIGNALS
#endif
      RunImpl(testResults);
  }
  catch (AssertException const& e)
  {
    testResults.OnTestFailure( TestDetails(m_details.testName,
					   m_details.suiteName,
					   e.Filename(),
					   e.LineNumber()),
			       e.what());
  }
  catch (std::exception const& e)
  {
//     MemoryOutStream stream;
//     stream
    String s;
    s << "Unhandled exception: " << e.what();
    testResults.OnTestFailure(m_details, s);
  }
  catch (...)
  {
    testResults.OnTestFailure(m_details, "Unhandled exception: Crash!");
  }
}

void Test::RunImpl (TestResults&) const
{}

} /* namespace Test */
} /* namespace SAT */
