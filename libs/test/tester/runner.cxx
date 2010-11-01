/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   runner.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "runner.h"
#include "results.h"
#include "testbase.h"
#include "testlist.h"
#include "reporter.h"
#include "repstdout.h"
#include "repxml.h"

#include "base/common/timer.h"

#include "newdisable.h"
#include <iostream>
#include <cstring>
#include <fstream>
#include "newenable.h"

namespace SAT {
namespace Test {

int RunAllTests (TestReporter   &reporter,
		 TestList const &list,
		 char const     *suiteName,
		 int const       maxTestTimeInMs)
{
  TestResults result (&reporter);

  Timer overallTimer;
  overallTimer.Start();

  Test const* curTest = list.GetHead();
  while (curTest != 0)
  {
    if (suiteName == 0 || !std::strcmp(curTest->m_details.suiteName, suiteName))
    {
      Timer testTimer;
      testTimer.Start ();
      result.OnTestStart (curTest->m_details);

      curTest->Run (result);

      testTimer.Stop ();
      double const testTimeInMs = testTimer.GetWallclockTime ();
      if (maxTestTimeInMs > 0. &&
	  testTimeInMs > maxTestTimeInMs &&
	  !curTest->m_timeConstraintExempt)
      {
	String s;
	s << "Global time constraint failed. Expected under "
	  << maxTestTimeInMs << "ms but took " << testTimeInMs << "ms.";
	result.OnTestFailure (curTest->m_details, s);
      }
      result.OnTestFinish(curTest->m_details, testTimeInMs);
    }

    curTest = curTest->next;
  }

  overallTimer.Stop ();
  double const secondsElapsed = overallTimer.GetWallclockTime ();
  reporter.ReportSummary (result.GetTotalTestCount(),
			  result.GetFailedTestCount(),
			  result.GetFailureCount(),
			  secondsElapsed);

  return result.GetFailureCount();
}

int RunAllTests (int argc, char **argv)
{
  //--stdout (default) --xml --bench --test (default) --file
  //  TestReporterStdout reporter;

  bool bench = false;
  bool xml = false;
  char *filename = NULL;

  for (int i=1; i<argc; i++)
  {
    if (!strcmp(argv[i], "--bench"))
      bench = true;
    else if (!strcmp(argv[i], "--xml"))
      xml = true;
    else if (!strcmp(argv[i], "--file"))
      filename = argv[++i];
  }

  TestReporter *rep;
  std::ostream *out;
  std::ofstream ofs;
  if (filename)
  {
    ofs.open (filename, std::ios::app);
    out = &ofs;
  }
  else
  {
    out = &std::cout;
  }

  if (xml)
    rep = new XmlTestReporter (*out, bench);
  else
    rep = new TestReporterStdout ();

  int retval;
  retval = RunAllTests(*rep, Test::GetTestList(), 0);
  delete rep;

  return retval;
}

} /* namespace Test */
} /* namespace SAT */
