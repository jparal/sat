/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   repxml.h
 * @brief  Reporter with XML output
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REPXML_H__
#define __SAT_REPXML_H__

#include <iosfwd>

#include "reporter.h"
#include "repdeferred.h"

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

/**
 * \brief This class translate results into XML data format
 */
class XmlTestReporter : public DeferredTestReporter
{
public:
  XmlTestReporter (std::ostream& ostream, bool bench = false);

  virtual void ReportSummary (int totalTestCount,
			      int failedTestCount,
			      int failureCount,
			      float secondsElapsed);

private:
  XmlTestReporter (XmlTestReporter const&);
  XmlTestReporter& operator= (XmlTestReporter const&);

  void AddXmlElement (std::ostream& os, char const* encoding);
  void BeginResults (std::ostream& os,
		     int totalTestCount,
		     int failedTestCount,
		     int failureCount,
		     float secondsElapsed);
  void EndResults (std::ostream& os);
  void BeginTest (std::ostream& os, DeferredTestResult const& result);
  void AddFailure (std::ostream& os, DeferredTestResult const& result);
  void EndTest (std::ostream& os, DeferredTestResult const& result);

  std::ostream& m_ostream;
  bool m_bench;
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_REPXML_H__ */
