/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   testlist.h
 * @brief  Very simple linked list of tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TESTLIST_H__
#define __SAT_TESTLIST_H__

/** @addtogroup test_tester
 *  @{
 */

#include "testbase.h"

namespace SAT {
namespace Test {

class Test;

/**
 * \brief Very simple linked list of tests
 * We dont't need any extra fancy things.
 */
class TestList
{
public:
  /// Constructor
  TestList ();

  /// Add next test on the end of list
  void Add (Test* test);

  /// Return Head of the TestList
  const Test* GetHead() const;

private:
  Test* m_head;
  Test* m_tail;
};

class ListAdder
{
public:
  ListAdder (TestList& list, Test* test);
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_TESTLIST_H__ */
