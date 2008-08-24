/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   exception.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include <cstring>

#include "exception.h"

namespace SAT {
namespace Test {

AssertException::AssertException (char const* description,
				  char const* filename,
				  int const lineNumber)
  : m_lineNumber(lineNumber)
{
  std::strcpy(m_description, description);
  std::strcpy(m_filename, filename);
}

AssertException::~AssertException () throw()
{
}

char const* AssertException::what () const throw()
{
  return m_description;
}

char const* AssertException::Filename () const
{
  return m_filename;
}

int AssertException::LineNumber () const
{
  return m_lineNumber;
}

} /* namespace Test */
} /* namespace SAT */
