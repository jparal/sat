/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repxml.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "repxml.h"

#include <iostream>
#include <sstream>
#include <string>

using std::string;
using std::ostringstream;
using std::ostream;

namespace {

void ReplaceChar (string& str, char const c, string const& replacement)
{
  for (size_t pos = str.find(c);
       pos != string::npos;
       pos = str.find(c, pos + 1))
    str.replace(pos, 1, replacement);
}

string XmlEscape (char const* value)
{
  string escaped = value;

  ReplaceChar(escaped, '&', "&amp;");
  ReplaceChar(escaped, '<', "&lt;");
  ReplaceChar(escaped, '>', "&gt;");
  ReplaceChar(escaped, '\'', "&apos;");
  ReplaceChar(escaped, '\"', "&quot;");

  return escaped;
}

string BuildFailureMessage (string const& file,
			    int const line,
			    string const& message)
{
  ostringstream failureMessage;
  failureMessage << "file=\"" << file << "\" ";
  failureMessage << "line=\"" << line << "\" ";
  failureMessage << "check=\"" << message << "\"";
  return failureMessage.str();
}

}

namespace SAT {
namespace Test {

XmlTestReporter::XmlTestReporter(ostream& ostream, bool bench)
  : m_ostream(ostream), m_bench (bench)
{
}

void XmlTestReporter::ReportSummary (int const totalTestCount,
				     int const failedTestCount,
				     int const failureCount,
				     float const secondsElapsed)
{
  AddXmlElement (m_ostream, NULL);

  BeginResults (m_ostream, totalTestCount, failedTestCount,
		failureCount, secondsElapsed);

  DeferredTestResultList const& results = GetResults();
  for (DeferredTestResultList::const_iterator i = results.begin();
       i != results.end(); ++i)
  {
    BeginTest(m_ostream, *i);

    if (i->failed)
      AddFailure(m_ostream, *i);

    EndTest(m_ostream, *i);
  }

  EndResults(m_ostream);
}

void XmlTestReporter::AddXmlElement (ostream& os, char const* encoding)
{
  os << "<?xml version=\"1.0\"";

  if (encoding != NULL)
    os << " encoding=\"" << encoding << "\"";

  os << "?>\n";
}

void XmlTestReporter::BeginResults (std::ostream& os,
				    int const totalTestCount,
				    int const failedTestCount,
				    int const failureCount,
				    float const secondsElapsed)
{
  if (m_bench)
  {
    os << "<benchmark"
       << " benchs=\"" << totalTestCount << "\""
       << " fail=\"" << failedTestCount << "\""
       << " failures=\"" << failureCount << "\""
       << " time=\"" << secondsElapsed << "\""
       << ">\n";
  } else
  {
    os << "<results"
       << " tests=\"" << totalTestCount << "\""
       << " fail=\"" << failedTestCount << "\""
       << " failures=\"" << failureCount << "\""
       << " time=\"" << secondsElapsed << "\""
       << ">\n";
  }
}

void XmlTestReporter::EndResults (std::ostream& os)
{
  if (m_bench)
    os << "</benchmark>\n";
  else
    os << "</results>\n";
}

void XmlTestReporter::BeginTest (std::ostream& os,
				 DeferredTestResult const& result)
{
  if (m_bench)
    os << "  <bench"
       << " suite=\"" << result.suiteName << "\""
       << " name=\"" << result.testName << "\""
       << " time=\"" << result.timeElapsed << "\"";
  else
    os << "  <test"
       << " suite=\"" << result.suiteName << "\""
       << " name=\"" << result.testName << "\""
       << " time=\"" << result.timeElapsed << "\"";
}

void XmlTestReporter::EndTest (std::ostream& os,
			       DeferredTestResult const& result)
{
  if (result.failed)
  {
    if (m_bench)
      os << "  </bench>\n";
    else
      os << "  </test>\n";
  } else
  {
    os << "/>\n";
  }
}

void XmlTestReporter::AddFailure (std::ostream& os,
				  DeferredTestResult const& result)
{
  os << ">\n"; // close <test> element

  string const escapedMessage = XmlEscape(result.failureMessage);
  string const message = BuildFailureMessage(result.failureFile,
					     result.failureLine,
					     escapedMessage);

  os << "    <failure " << message << " />\n";
}

} /* namespace Test */
} /* namespace SAT */
