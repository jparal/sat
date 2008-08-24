/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   testlist.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "testlist.h"
#include "base/sys/assert.h"

namespace SAT {
namespace Test {

TestList::TestList ()
  : m_head(0) , m_tail(0)
{
}

void TestList::Add (Test* test)
{
  if (m_tail == 0)
  {
    SAT_ASSERT (m_head == 0);
    m_head = test;
    m_tail = test;
  }
  else
  {
    m_tail->next = test;
    m_tail = test;
  }
}

const Test* TestList::GetHead () const
{
  return m_head;
}

ListAdder::ListAdder (TestList& list, Test* test)
{
  list.Add (test);
}

} /* namespace Test */
} /* namespace SAT */
