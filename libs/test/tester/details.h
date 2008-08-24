/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   details.h
 * @brief  Details about test
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DETAILS_H__
#define __SAT_DETAILS_H__

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

class TestDetails
{
public:
  TestDetails (char const* testName,
	       char const* suiteName,
	       char const* filename,
	       int lineNumber);

  TestDetails (const TestDetails& details, int lineNumber);

  char const* const suiteName;
  char const* const testName;
  char const* const filename;
  int const lineNumber;

  // Why is it public? --> http://gcc.gnu.org/bugs.html#cxx_rvalbind
  TestDetails (TestDetails const&); 

private:
  TestDetails& operator=(TestDetails const&);
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_DETAILS_H__ */
