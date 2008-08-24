/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   value.cpp
 * @brief  Container class for basic types
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "value.h"
#include "base/sys/inline.h"

SAT_INLINE
Value::Value ()
{
  m_type = TypeTraits<void>::GetID ();
}

SAT_INLINE
Value::Value (bool v)
{
  m_var.dbool = v;
  m_type = TypeTraits<bool>::GetID ();
}

SAT_INLINE
Value::Value (double v)
{
  m_var.ddouble = v;
  m_type = TypeTraits<double>::GetID ();
}

SAT_INLINE
Value::operator double ()
{
  switch (m_type)
  {
  case bool_id:
    return double(m_var.dbool);
  case double_id:
    return m_var.ddouble;
  };
  return 0.;
}

SAT_INLINE
Value::operator bool ()
{
  switch (m_type)
  {
  case bool_id:
    return m_var.dbool;
  case double_id:
    return (bool)m_var.ddouble;
  };
  return false;
}
