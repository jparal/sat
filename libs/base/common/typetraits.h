/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   typetraits.h
 * @brief  Type Traits.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TYPETRAITS_H__
#define __SAT_TYPETRAITS_H__

#include "string.h"
#include "array.h"

/** @addtogroup base_common
 *  @{
 */

class ConfigEntry;

enum TypeID
{
  void_id,
  bool_id,
  char_id,
  schar_id,
  uchar_id,
  short_id,
  ushort_id,
  int_id,
  unsigned_id,
  long_id,
  ulong_id,
  float_id,
  ldouble_id,
  double_id,
  string_id,
  array_char_id,
  array_bool_id,
  array_int_id,
  array_float_id,
  array_double_id,
  array_string_id,
  config_entry_id
};

typedef int32_t typeid_t;

template< class T >
struct TypeTraits
{
  static typeid_t GetID ();
  static typeid_t GetMax ();
};


#define TYPETRAITS_GETID_SPECIALIZE(type, id)		\
  template <> inline					\
  typeid_t TypeTraits< type >::GetID ()			\
  { return (typeid_t)id; }

#define TYPETRAITS_SPECIALIZE(type, id)		\
  TYPETRAITS_GETID_SPECIALIZE(type,id)		\

TYPETRAITS_SPECIALIZE (void,            void_id)
TYPETRAITS_SPECIALIZE (bool,            bool_id)
TYPETRAITS_SPECIALIZE (char,            char_id)
TYPETRAITS_SPECIALIZE (signed char,     schar_id)
TYPETRAITS_SPECIALIZE (unsigned char,   uchar_id)
TYPETRAITS_SPECIALIZE (short,           short_id)
TYPETRAITS_SPECIALIZE (unsigned short,  ushort_id)
TYPETRAITS_SPECIALIZE (int,             int_id)
TYPETRAITS_SPECIALIZE (unsigned,        unsigned_id)
TYPETRAITS_SPECIALIZE (long,            long_id)
TYPETRAITS_SPECIALIZE (unsigned long,   ulong_id)
TYPETRAITS_SPECIALIZE (float,           float_id)
TYPETRAITS_SPECIALIZE (double,          double_id)
TYPETRAITS_SPECIALIZE (long double,     ldouble_id)
TYPETRAITS_SPECIALIZE (Array<char>,     array_char_id)
TYPETRAITS_SPECIALIZE (Array<bool>,     array_bool_id)
TYPETRAITS_SPECIALIZE (Array<int>,      array_int_id)
TYPETRAITS_SPECIALIZE (Array<float>,    array_float_id)
TYPETRAITS_SPECIALIZE (Array<double>,   array_double_id)
TYPETRAITS_SPECIALIZE (Array<String>,   array_string_id)
TYPETRAITS_SPECIALIZE (String,          string_id)
TYPETRAITS_SPECIALIZE (ConfigEntry,     config_entry_id)

/** @} */

#endif /* __SAT_TYPETRAITS_H__ */
