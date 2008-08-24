/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   suite.h
 * @brief  Simple test suite definition
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SUITE_H__
#define __SAT_SUITE_H__

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

// namespace UnitTestSuite {

/// Return default test suite name
inline char const* GetSuiteName ()
{
  return "DefaultSuite";
}

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_SUITE_H__ */
