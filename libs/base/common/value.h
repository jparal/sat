/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   value.h
 * @brief  Container class for basic types.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_VALUE_H__
#define __SAT_VALUE_H__

#include "typetraits.h"
#include "string.h"

/// @addtogroup base_common
/// @{

/**
 * Container class for basic types with smart casting into the different types.
 * @warning This class isn't optimized for speed due to the casting.
 */
class Value
{
public:
  Value ();
  Value (bool v);
  Value (double v);
  Value (int v);
  Value (String v);

  operator bool ();
  operator double ();
  operator int ();
  operator String ();

private:

  union Variable
  {
    bool dbool;
    double ddouble;
    int dint;
  };
  String dstring;

  typeid_t m_type;
  Variable m_var;
};

/// @}

#endif /* __SAT_VALUE_H__ */
