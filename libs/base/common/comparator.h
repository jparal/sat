/*
  Template providing various comparison and ordering functions.
  Copyright (C) 2005 by Eric Sunshine

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
#ifndef SAT_COMPARATOR_H
#define SAT_COMPARATOR_H

/// @file
/// Template providing various comparison and ordering functions.

//#include "string.h"
class String;
class StringBase;

/// @addtogroup base_common
/// @{

/// A template providing various comparison and ordering functions.
template <class T1, class T2>
class Comparator
{
public:
  /**
   * Compare two objects of the same type or different types (T1 and T2).
   * @param r1 Reference to first object.
   * @param r2 Reference to second object.
   * @return Zero if the objects are equal; less-than-zero if the first object
   *   is less than the second; or greater-than-zero if the first object is
   *   greater than the second.
   * @remarks Assumes the existence of T1::operator<(T2) and T2::operator<(T1).
   *   If T1 and T2 are the same type T, then only T::operator<(T) is assumed
   *   (naturally).
   * <p>
   * @remarks This is the default comparison function used by csArray<> for
   *   searching and sorting if the client does not provide a custom
   *   function. It is also used by csSet<> when checking for object
   *   containment.
   */
  static int Compare(T1 const &r1, T2 const &r2)
  {
    if (r1 < r2) return -1;
    else if (r2 < r1) return 1;
    else return 0;
  }
};

/**
 * Template that can be used as a base class for comparators for string
 * types. Assumes presence of `operator char const*()' (the cast operator).
 * Also works for normal C-strings.  Example:
 * @code
 * SAT_SPECIALIZE_TEMPLATE Comparator<MyString> :
 *   public ComparatorString<MyString> {};
 * @endcode
 */
template <class T>
class ComparatorString
{
public:
  static int Compare (T const& r1, T const& r2)
  {
    if (((const char*)r1) == 0)
    {
      return (((const char*)r2) == 0) ? 0 : 1;
    }
    else if (((const char*)r2) == 0)
    {
      return -1;
    }
    return strcmp ((const char*)r1, (const char*)r2);
  }
};

/**
 * Comparator<> specialization for strings that uses strcmp().
 */
template <>
class Comparator<const char*, const char*> :
  public ComparatorString<const char*> {};

/** @{ */
/**
 * Comparator<> specialization for String that uses strcmp().
 */
template <>
class Comparator<String, String> :
  public ComparatorString<String> {};
template <>
class Comparator<StringBase, StringBase> :
  public ComparatorString<StringBase> {};
/** @} */

/**
 * Template that can be used as a base class for comparators for POD (plain old
 * data) types. It uses memcmp() to compare the raw memory representing the two
 * items.  Example:
 * @code
 * SAT_SPECIALIZE_TEMPLATE Comparator<MyStruct> :
 *   public ComparatorStruct<MyStruct> {};
 * @endcode
 */
template<class T>
class ComparatorStruct
{
public:
  static int Compare (T const& r1, T const& r2)
  {
    return memcmp (&r1, &r2, sizeof (T));
  }
};

/// @}

#endif //SAT_COMPARATOR_H
