/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   exception.h
 * @brief  Helper exception for catching mechanism
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_EXCEPTION_H__
#define __SAT_EXCEPTION_H__

#include <exception>

/** @addtogroup test_tester
 *  @{
 */

namespace SAT {
namespace Test {

class AssertException : public std::exception
{
public:
  AssertException (char const* description,
		   char const* filename,
		   int lineNumber);

  virtual ~AssertException() throw();

  virtual char const* what() const throw();

  char const* Filename() const;
  int LineNumber() const;

private:
  char m_description[512];
  char m_filename[256];
  int m_lineNumber;
};

} /* namespace Test */
} /* namespace SAT */

/** @} */

#endif /* __SAT_EXCEPTION_H__ */
