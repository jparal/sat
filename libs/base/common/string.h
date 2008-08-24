/*
    Copyright (C) 2003 by Marten Svanfeldt
    influenced by Aapl by Adrian Thurston <adriant@ragel.ca>

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
/**
 * @file   string.h
 * @brief  String implementation inspired by String class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/07, @jparal}
 * @revmessg{Remove operator<< for std::ostream since it cause problems with
 *          parallel buffer. Probably due to the NULL pointer given to the
 *          stream. Moved to the StringBase class.}
 */

#ifndef __SAT_STRING_H__
#define __SAT_STRING_H__

#include "base/sys/porttypes.h"
#include "base/sys/format.h"
#include "base/sys/stdhdrs.h"
#include "base/sys/assert.h"
#include "strutil.h"

#include "newdisable.h"
#include <iostream>
#include "newenable.h"

/** @addtogroup base_common
 *  @{
 */

/**
 * This is a string class with a range of useful operators and type-safe
 * overloads.  Strings may contain arbitary binary data, including null bytes.
 * It also guarantees that a null-terminator always follows the last stored
 * character, thus you can safely use the return value from GetData() and
 * `operator char const*()' in calls to functions expecting C strings.  The
 * implicit null terminator is not included in the character count returned by
 * Length().
 * <p>
 * Like a typical C character string pointer, StringBase can also represent a
 * null pointer.  This allows a non-string to be distinguished from an empty
 * (zero-length) string.  The StringBase will represent a null-pointer in the
 * following cases:
 * - When constructed with no arguments (the default constructor).
 * - When constructed with an explicit null-pointer.
 * - When assigned a null-pointer via operator=((char const*)0).
 * - After an invocation of Replace((char const*)0).
 * - After invocation of StringBase::free() or any method which is
 *   documented as invoking Free() as a side-effect, such as ShrinkBestFit().
 * - After invocation of StringBase::detach().
 */
class StringBase
{
protected:
  /**
   * Default number of bytes by which allocation should grow.
   * *** IMPORTANT *** This must be a power of two (i.e. 8, 16, 32, 64, etc.).
   */
  enum { DEFAULT_GROW_BY = 64 };

  /// String buffer.
  char* Data;
  /// Length of string; not including null terminator.
  size_t Size;
  /// Size in bytes of allocated string buffer.
  size_t MaxSize;
  /**
   * Size in bytes by which allocated buffer is increased when needed. If this
   * value is zero, then growth occurs exponentially by doubling the size.
   */
  size_t GrowBy;

  /**
   * If necessary, increase the buffer capacity enough to hold \p NewSize
   * bytes.  Buffer capacity is increased in GrowBy increments or exponentially
   * depending upon configuration.
   */
  void ExpandIfNeeded (size_t NewSize);

  /**
   * Set the buffer to hold NewSize bytes. If \a soft is true it means
   * the buffer can be rounded up to reduce the number of allocations needed.
   */
  virtual void SetCapacityInternal (size_t NewSize, bool soft);

  /// Compute a new buffer size. Takes GrowBy into consideration.
  size_t ComputeNewSize (size_t NewSize);

  /**
   * Get a pointer to the null-terminated character array.
   * \return A C-string pointer to the null-terminated character array; or zero
   *   if the string represents a null-pointer.
   * \remarks See the class description for a discussion about how and when the
   *   string will represent a null-pointer.
   * \warning This returns a non-const pointer, so use this function with care.
   *   Call this only when you need to modify the string content. External
   *   clients are never allowed to directly modify the internal string buffer,
   *   which is why this function is not public.
   */
  virtual char* GetDataMutable ()
  { return Data; }

public:
  /**
   * Ask the string to allocate enough space to hold \p NewSize characters.
   * \remarks After calling this method, the string's internal capacity will be
   *   at least \p NewSize + 1 (one for the implicit null terminator).  Never
   *   shrinks capacity.  If you need to actually reclaim memory, then use
   *   Free() or ShrinkBestFit().
   */
  void SetCapacity (size_t NewSize);

  /**
   * Return the current capacity, not including the space for the implicit null
   * terminator.
   */
  virtual size_t GetCapacity() const
  { return MaxSize > 0 ? MaxSize - 1 : 0; }

  /**
   * Append a null-terminated C-string to this one.
   * \param Str String which will be appended.
   * \param Count Number of characters from Str to append; if -1 (the default),
   *   then all characters from Str will be appended.
   * \return Reference to itself.
   */
  StringBase& Append (const char* Str, size_t Count = (size_t)-1);

  /**
   * Append a null-terminated wide string to this one.
   * \param Str String which will be appended.
   * \param Count Number of characters from Str to append; if -1 (the default),
   *   then all characters from Str will be appended.
   * \return Reference to itself.
   * \remarks The string will be appended as UTF-8.
   */
  //  StringBase& Append (const wchar_t* Str, size_t Count = (size_t)-1);

  /**
   * Append a string to this one.
   * \param Str String which will be appended.
   * \param Count Number of characters from Str to append; if -1 (the default),
   *   then all characters from Str will be appended.
   * \return Reference to itself.
   */
  StringBase& Append (const StringBase& Str, size_t Count = (size_t)-1);

  /**
   * Append a signed character to this string.
   * \return Reference to itself.
   */
  StringBase& Append (char c);

  /**
   * Append an unsigned character to this string.
   * \return Reference to itself.
   */
  /*StringBase& Append (unsigned char c)
  { return Append(char(c)); }*/

  /// Append a boolean (as a number -- 1 or 0) to this string.
  StringBase& Append (bool b) { return Append (b ? "1" : "0"); }

  /** @{ */
  /**
   * Append a string formatted using cs_snprintf()-style formatting directives.
   */
  StringBase& AppendFmt (const char* format, ...) SAT_FORMAT_PRINTF (2, 3);
  StringBase& AppendFmtV (const char* format, va_list args);
  /** @} */

  /** @{ */
  /// Append the value, in formatted form, to this string.
  StringBase& Append (short v) { return AppendFmt ("%hd", v); }
  StringBase& Append (unsigned short v) { return AppendFmt ("%hu", v); }
  StringBase& Append (int v) { return AppendFmt ("%d", v); }
  StringBase& Append (unsigned int v) { return AppendFmt ("%u", v); }
  StringBase& Append (long v) { return AppendFmt ("%ld", v); }
  StringBase& Append (unsigned long v) { return AppendFmt ("%lu", v); }
  StringBase& Append (float v) { return AppendFmt ("%g", v); }
  StringBase& Append (double v) { return AppendFmt ("%g", v); }
  /** @} */

  /**
   * Create an empty StringBase object.
   * \remarks The newly constructed string represents a null-pointer.
   */
  StringBase () : Data (0), Size (0), MaxSize (0), GrowBy (DEFAULT_GROW_BY)
  {}

  /**
   * Create a StringBase object and reserve space for at least \p Length
   * characters.
   * \remarks The newly constructed string represents a non-null zero-length
   *   string.
   */
  StringBase (size_t Length) : Data (0), Size (0), MaxSize (0),
    GrowBy (DEFAULT_GROW_BY)
  { SetCapacity (Length); }

  /**
   * Copy constructor.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if the template string represented a null-pointer.
   */
  StringBase (const StringBase& copy) : Data (0), Size (0), MaxSize (0),
    GrowBy (DEFAULT_GROW_BY)
  { Append (copy); }

  /**
   * Create a StringBase object from a null-terminated C string.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if the input argument is a null-pointer.
   */
  StringBase (const char* src) : Data (0), Size (0), MaxSize (0),
    GrowBy (DEFAULT_GROW_BY)
  { Append (src); }

  /**
   * Create a StringBase object from a null-terminated wide string.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if the input argument is a null-pointer.
   * \remarks The string will be stored as UTF-8.
   */
//   StringBase (const wchar_t* src) : Data (0), Size (0), MaxSize (0),
//     GrowBy (DEFAULT_GROW_BY)
//   { Append (src); }

  /**
   * Create a StringBase object from a C string, given the length.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if the input argument is a null-pointer.
   */
  StringBase (const char* src, size_t _length) : Data (0), Size (0),
        MaxSize (0), GrowBy (DEFAULT_GROW_BY)
  { Append (src, _length); }

  /**
   * Create a StringBase object from a wide string, given the length.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if the input argument is a null-pointer.
   * \remarks The string will be stored as UTF-8.
   */
//   StringBase (const wchar_t* src, size_t _length) : Data (0), Size (0),
//         MaxSize (0), GrowBy (DEFAULT_GROW_BY)
//   { Append (src, _length); }

  /// Create a StringBase object from a single signed character.
  StringBase (char c) : Data (0), Size (0), MaxSize (0),
    GrowBy (DEFAULT_GROW_BY)
  { Append (c); }

  /// Create a StringBase object from a single unsigned character.
  StringBase (unsigned char c) : Data(0), Size (0), MaxSize (0),
    GrowBy (DEFAULT_GROW_BY)
  { Append ((char) c); }

  /// Destroy the StringBase.
  virtual ~StringBase ();

  /**
   * Advise the string that it should grow its allocated buffer by
   * approximately this many bytes when more space is required. This is an
   * optimization to avoid excessive memory reallocation and heap management,
   * which can be quite slow.
   * \remarks This value is only a suggestion.  The actual value by which it
   *   grows may be rounded up or down to an implementation-dependent
   *   allocation multiple.
   * <p>
   * \remarks If the value is zero, then the internal buffer grows
   *   exponentially by doubling its size, rather than by fixed increments.
   */
  void SetGrowsBy(size_t);

  /**
   * Return the number of bytes by which the string grows.
   * \remarks If the return value is zero, then the internal buffer grows
   *   exponentially by doubling its size, rather than by fixed increments.
   */
  size_t GetGrowsBy() const
  { return GrowBy; }

  /**
   * Free the memory allocated for the string.
   * \remarks Following a call to this method, invocations of GetData() and
   *   'operator char const*' will return a null pointer (until some new
   *   content is added to the string).
   */
  virtual void Free ();

  /**
   * Truncate the string.
   * \param Len The number of characters to which the string should be
   *   truncated (possibly 0).
   * \return Reference to itself.
   * \remarks Will only make a string shorter; will never extend it.
   *   This method does not reclaim memory; it merely shortens the string,
   *   which means that Truncate(0) is a handy method of clearing the string,
   *   without the overhead of slow heap management.  This may be important if
   *   you want to re-use the same string many times over.  If you need to
   *   reclaim memory after truncating the string, then invoke ShrinkBestFit().
   *   GetData() and 'operator char const*' will return a non-null zero-length
   *   string if you truncate the string to 0 characters, unless the string
   *   had already represented a null-pointer, in which case it will continue
   *   to represent a null-pointer after truncation.
   */
  StringBase& Truncate (size_t Len);

  /**
   * Clear the string (so that it contains only a null terminator).
   * \return Reference to itself.
   * \remarks This is rigidly equivalent to Truncate(0).
   */
  StringBase& Empty() { return Truncate (0); }

  /**
   * Set string buffer capacity to hold exactly the current content.
   * \return Reference to itself.
   * \remarks If the string length is greater than zero, then the buffer's
   *   capacity will be adjusted to exactly that size.  If the string length is
   *   zero, then this is equivalent to an invocation of Free(), which means
   *   that GetData() and 'operator char const*' will return a null pointer
   *   after reclamation.
   */
  virtual void ShrinkBestFit ();

  /**
   * Set string buffer capacity to hold exactly the current content.
   * \return Reference to itself.
   * \remarks If the string length is greater than zero, then the buffer's
   *   capacity will be adjusted to exactly that size.  If the string length is
   *   zero, then this is equivalent to an invocation of Free(), which means
   *   that GetData() and 'operator char const*' will return a null pointer
   *   after reclamation.
   */
  StringBase& Reclaim () { ShrinkBestFit(); return *this; }

  /**
   * Clear the string (so that it contains only a null terminator).
   * \return Reference to itself.
   * \remarks This is rigidly equivalent to Empty(), but more idiomatic in
   *   terms of human language.
   */
  StringBase& Clear () { return Empty(); }

  /**
   * Get a pointer to the null-terminated character array.
   * \return A C-string pointer to the null-terminated character array; or zero
   *   if the string represents a null-pointer.
   * \remarks See the class description for a discussion about how and when the
   *   string will represent a null-pointer.
   */
  virtual char const* GetData () const
  { return Data; }

  /**
   * Get a pointer to the null-terminated character array.
   * \return A C-string pointer to the null-terminated character array.
   * \remarks Unlike GetData(), this will always return a valid, non-null
   *   C-string, even if the underlying representation is that of a
   *   null-pointer (in which case, it will return a zero-length C-string.
   *   This is a handy convenience which makes it possible to use the result
   *   directly without having to perform a null check first.
   */
   char const* GetDataSafe() const
   { char const* p = GetData(); return p != 0 ? p : ""; }

  /**
   * Query string length.
   * \return The string length.
   * \remarks The returned length does not count the implicit null terminator.
   */
  size_t Length () const
  { return Size; }

  /**
   * Check if string is empty.
   * \return True if the string is empty; false if it is not.
   * \remarks This is rigidly equivalent to the expression 'Length() == 0'.
   */
  bool IsEmpty () const
  { return (Size == 0); }

  /// Get a modifiable reference to n'th character.
  char& operator [] (size_t n)
  {
    SAT_ASSERT (n < Size);
    return GetDataMutable()[n];
  }

  /// Get n'th character.
  char operator [] (size_t n) const
  {
    SAT_ASSERT (n < Size);
    return GetData()[n];
  }

  /**
   * Set the n'th character.
   * \remarks The n'th character position must be a valid position in the
   *   string.  You can not expand the string by setting a character beyond the
   *   end of string.
   */
  void SetAt (size_t n, const char c)
  {
    SAT_ASSERT (n < Size);
    GetDataMutable() [n] = c;
  }

  /// Get the n'th character.
  char GetAt (size_t n) const
  {
    SAT_ASSERT (n < Size);
    return GetData() [n];
  }

  /**
   * Delete a range of characters from the string.
   * \param Pos Beginning of range to be deleted (zero-based).
   * \param Count Number of characters to delete.
   * \return Reference to itself.
   */
  StringBase& DeleteAt (size_t Pos, size_t Count = 1);

  /**
   * Insert another string into this one.
   * \param Pos Position at which to insert the other string (zero-based).
   * \param Str String to insert.
   * \return Reference to itself.
   */
  StringBase& Insert (size_t Pos, const StringBase& Str);

  /**
   * Insert another string into this one.
   * \param Pos Position at which to insert the other string (zero-based).
   * \param Str String to insert.
   * \return Reference to itself.
   */
  StringBase& Insert (size_t Pos, const char* Str);

  /**
   * Insert another string into this one.
   * \param Pos Position at which to insert the other string (zero-based).
   * \param C Character to insert.
   * \return Reference to itself.
   */
  StringBase& Insert (size_t Pos, char C);

  /**
   * Overlay another string onto a part of this string.
   * \param Pos Position at which to insert the other string (zero-based).
   * \param Str String which will be overlayed atop this string.
   * \return Reference to itself.
   * \remarks The target string will grow as necessary to accept the new
   *   string.
   */
  StringBase& Overwrite (size_t Pos, const StringBase& Str);

  /**
   * Copy and return a portion of this string.
   * \param start Start position of slice (zero-based).
   * \param len Number of characters in slice.
   * \return The indicated string slice.
   */
  StringBase Slice (size_t start, size_t len = (size_t)-1) const;

  /**
   * Add new lines at every maxChars and indent from left.
   * This function consider already inserted new lines and in this case start
   * indenting from the begining.
   * \param maxChars Number of chars on line
   * \param indent Number of characters to indent from left.
   * \todo Consider words in formating as well.
   */
  void Format (size_t maxChars, size_t indent = 0);

  /**
   * Copy a portion of this string.
   * \param sub Strign which will receive the indicated substring copy.
   * \param start Start position of slice (zero-based).
   * \param len Number of characters in slice.
   * \remarks Use this method instead of Slice() for cases where you expect to
   *   extract many substrings in a tight loop, and want to avoid the overhead
   *   of allocation of a new string object for each operation.  Simply re-use
   *   'sub' for each operation.
   */
  void SubString (StringBase& sub, size_t start,
    size_t len = (size_t)-1) const;

  /**
   * Find the first occurrence of a character in the string.
   * \param c Character to locate.
   * \param pos Start position of search (default 0).
   * \return First position of character, or (size_t)-1 if not found.
   */
  size_t FindFirst (char c, size_t pos = 0) const;

  /**
   * Find the first occurrence of any of a set of characters in the string.
   * \param c Characters to locate.
   * \param pos Start position of search (default 0).
   * \return First position of character, or (size_t)-1 if not found.
   */
  size_t FindFirst (const char *c, size_t pos = 0) const;

  /**
   * Find the last occurrence of a character in the string.
   * \param c Character to locate.
   * \param pos Start position of reverse search.  Specify (size_t)-1 if you
   *   want the search to begin at the very end of string.
   * \return Last position of character, or (size_t)-1 if not found.
   */
  size_t FindLast (char c, size_t pos = (size_t)-1) const;

  /**
   * Find the first occurrence of \p search in this string starting at \p pos.
   * \param search String to locate.
   * \param pos Start position of search (default 0).
   * \return First position of \p search, or (size_t)-1 if not found.
   */
  size_t Find (const char* search, size_t pos = 0) const;

  /**
   * Find the first occurrence of \p search in this string starting at \p pos.
   * \param search String to locate.
   * \param pos Start position of search (default 0).
   * \return First position of \p search, or (size_t)-1 if not found.
   * \deprecated Use Find() instead.
   */
  /* CS_DEPRECATED_METHOD */
  size_t FindStr (const char* search, size_t pos = 0) const
  { return Find(search, pos); }

  /**
   * Find all occurrences of \p search in this string and replace them with
   * \p replacement.
   */
  void ReplaceAll (const char* search, const char* replacement);

  /**
   * Find all occurrences of \p search in this string and replace them with
   * \p replacement.
   * \deprecated Use ReplaceAll() instead.
   */
  /* CS_DEPRECATED_METHOD */
  void FindReplace (const char* search, const char* replacement)
  { ReplaceAll(search, replacement); }

  /**
   * Format this string using cs_snprintf()-style formatting directives.
   * \return Reference to itself.
   * \remarks Automatically allocates sufficient memory to hold result.  Newly
   *   formatted string replaces previous string value.
   */
  StringBase& Format (const char* format, ...) SAT_FORMAT_PRINTF (2, 3);

  /**
   * Format this string using cs_snprintf() formatting directives in a va_list.
   * \return Reference to itself.
   * \remarks Automatically allocates sufficient memory to hold result.  Newly
   *   formatted string replaces previous string value.
   */
  StringBase& FormatV (const char* format, va_list args);

  /**
   * Replace contents of this string with the contents of another.
   * \param Str String from which new content of this string will be copied.
   * \param Count Number of characters to copy.  If (size_t)-1 is specified,
   *   then all characters will be copied.
   * \return Reference to itself.
   * \remarks This string will represent a null-pointer after replacement if
   *   and only if Str represents a null-pointer.
   */
  StringBase& Replace (const StringBase& Str, size_t Count = (size_t)-1);

  /**
   * Replace contents of this string with the contents of another.
   * \param Str String from which new content of this string will be copied.
   * \param Count Number of characters to copy.  If (size_t)-1 is specified,
   *   then all characters will be copied.
   * \return Reference to itself.
   * \remarks This string will represent a null-pointer after replacement if
   *   and only if Str is a null pointer.
   */
  StringBase& Replace (const char* Str, size_t Count = (size_t)-1);

  /**
   * Replace contents of this string with the value in formatted form.
   * \remarks Internally uses the various flavours of Append().
   */
  template<typename T>
  StringBase& Replace (T const& val) { Truncate (0); return Append (val); }

  /**
   * Check if another string is equal to this one.
   * \param iStr Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-sensitive.
   */
  bool Compare (const StringBase& iStr) const
  {
    if (&iStr == this)
      return true;
    size_t const n = iStr.Length();
    if (Size != n)
      return false;
    if (Size == 0 && n == 0)
      return true;
    return (memcmp (GetDataSafe(), iStr.GetDataSafe (), Size) == 0);
  }

  /**
   * Check if a null-terminated C- string is equal to this string.
   * \param iStr Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-sensitive.
   */
  bool Compare (const char* iStr) const
  { return (strcmp (GetDataSafe(), iStr) == 0); }

  /**
   * Check if another string is equal to this one.
   * \param iStr Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-insensitive.
   */
  bool CompareNoCase (const StringBase& iStr) const
  {
    if (&iStr == this)
      return true;
    size_t const n = iStr.Length();
    if (Size != n)
      return false;
    if (Size == 0 && n == 0)
      return true;
    return (StrNCaseCmp (GetDataSafe(), iStr.GetDataSafe(), Size) == 0);
  }

  /**
   * Check if a null-terminated C- string is equal to this string.
   * \param iStr Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-insensitive.
   */
  bool CompareNoCase (const char* iStr) const
  { return (StrCaseCmp (GetDataSafe(), iStr) == 0); }

  /**
   * Check if this string starts with another one.
   * \param iStr Other string.
   * \param ignore_case Causes the comparison to be case insensitive if true.
   * \return True if they are equal up to the length of iStr; false if not.
   */
  bool StartsWith (const StringBase& iStr, bool ignore_case = false) const
  {
    char const* p = GetDataSafe();
    if (&iStr == this)
      return true;
    size_t const n = iStr.Length();
    if (n == 0)
      return true;
    if (n > Size)
      return false;
    SAT_ASSERT(p != 0);
    if (ignore_case)
      return (StrNCaseCmp (p, iStr.GetDataSafe (), n) == 0);
    else
      return (strncmp (p, iStr.GetDataSafe (), n) == 0);
  }

  /**
   * Check if this string starts with a null-terminated C- string.
   * \param iStr Other string.
   * \param ignore_case Causes the comparison to be case insensitive if true.
   * \return True if they are equal up to the length of iStr; false if not.
   */
  bool StartsWith (const char* iStr, bool ignore_case = false) const
  {
    char const* p = GetDataSafe();
    if (iStr == 0)
      return false;
    size_t const n = strlen (iStr);
    if (n == 0)
      return true;
    if (n > Size)
      return false;
    SAT_ASSERT(p != 0);
    if (ignore_case)
      return (StrNCaseCmp (p, iStr, n) == 0);
    else
      return (strncmp (p, iStr, n) == 0);
  }

  /**
   * Get a copy of this string.
   * \remarks The newly constructed string will represent a null-pointer if and
   *   only if this string represents a null-pointer.
   */
  StringBase Clone () const
  { return StringBase (*this); }

  /**
   * Trim leading whitespace.
   * \return Reference to itself.
   * \remarks This is equivalent to Truncate(n) where 'n' is the last
   *   non-whitespace character, or zero if the string is composed entirely of
   *   whitespace.
   */
  StringBase& LTrim();

  /**
   * Trim trailing whitespace.
   * \return Reference to itself.
   * \remarks This is equivalent to DeleteAt(0,n) where 'n' is the first
   *   non-whitespace character, or Lenght() if the string is composed entirely
   *   of whitespace.
   */
  StringBase& RTrim();

  /**
   * Trim leading and trailing whitespace.
   * \return Reference to itself.
   * \remarks This is equivalent to LTrim() followed by RTrim().
   */
  StringBase& Trim();

  /**
   * Trim leading and trailing whitespace, and collapse all internal
   * whitespace to a single space.
   * \return Reference to itself.
   */
  StringBase& Collapse();

  /**
   * Pad to a specified size with leading characters.
   * \param NewSize Size to which the string should grow.
   * \param PadChar Character with which to pad the string (default is space).
   * \return Reference to itself.
   * \remarks Never shortens the string.  If NewSize is less than or equal to
   *   Length(), nothing happens.
   */
  StringBase& PadLeft (size_t NewSize, char PadChar = ' ');

  /**
   * Pad to a specified size with trailing characters.
   * \param NewSize Size to which the string should grow.
   * \param PadChar Character with which to pad the string (default is space).
   * \return Reference to itself.
   * \remarks Never shortens the string.  If NewSize is less than or equal to
   *   Length(), nothing happens.
   */
  StringBase& PadRight (size_t NewSize, char PadChar = ' ');

  /**
   * Pad to a specified size with leading and trailing characters so as to
   * center the string.
   * \param NewSize Size to which the string should grow.
   * \param PadChar Character with which to pad the string (default is space).
   * \return Reference to itself.
   * \remarks Never shortens the string.  If NewSize is less than or equal to
   *   Length(), nothing happens.  If the left and right sides can not be
   *   padded equally, then the right side will gain the extra one-character
   *   padding.
   */
  StringBase& PadCenter (size_t NewSize, char PadChar = ' ');

  /**
   * Assign a formatted value to this string.
   */
  template<typename T>
  const StringBase& operator = (T const& s) { return Replace (s); }

  /// Assign another string to this one
  const StringBase& operator = (const StringBase& copy)
  { Replace(copy); return *this; }

  /**
   * Append a formatted value to this string.
   */
  template<typename T>
  StringBase &operator += (T const& s) { return Append (s); }

  // Specialization which prevents gcc from barfing on strings allocated via
  // CS_ALLOC_STACK_ARRAY().
  StringBase &operator += (char const* s)
  { return Append(s); }

  /// Add another string to this one and return the result as a new string.
  StringBase operator + (const StringBase &iStr) const
  { return Clone ().Append (iStr); }

  /**
   * Get a pointer to the null-terminated character array.
   * \return A C-string pointer to the null-terminated character array; or zero
   *   if the string represents a null-pointer.
   * \remarks See the class description for a discussion about how and when the
   *   string will represent a null-pointer.
   */
  operator const char* () const
  { return GetData (); }

  /// ostream operator
  friend std::ostream& operator<< (std::ostream &os, const StringBase &v)
  {
    os << v.GetDataSafe ();
    return os;
  }

  /**
   * Check if another string is equal to this one.
   * \param Str Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-sensitive.
   */
  bool operator == (const StringBase& Str) const
  { return Compare (Str); }
  /**
   * Check if another string is equal to this one.
   * \param Str Other string.
   * \return True if they are equal; false if not.
   * \remarks The comparison is case-sensitive.
   */
  bool operator == (const char* Str) const
  { return Compare (Str); }
  /**
   * Check if another string is less than this one.
   * \param Str Other string.
   * \return True if the string is 'lesser' than \a Str, false
   *   otherwise.
   */
  bool operator < (const StringBase& Str) const
  {
    return strcmp (GetDataSafe (), Str.GetDataSafe ()) < 0;
  }
  /**
   * Check if another string is less than this one.
   * \param Str Other string.
   * \return True if the string is 'lesser' than \a Str, false
   *   otherwise.
   */
  bool operator < (const char* Str) const
  {
    return strcmp (GetDataSafe (), Str) < 0;
  }
  /**
   * Check to see if a string is greater than this one.
   * \param Str Other string.
   * \return True if the string is 'greater' than \a Str, false
   *   otherwise.
   */
  bool operator > (const StringBase& Str) const
  {
    return strcmp (GetDataSafe (), Str.GetDataSafe ()) > 0;
  }
  /**
   * Check to see if a string is greater than this one.
   * \param Str Other string.
   * \return True if the string is 'greater' than \a Str, false
   *   otherwise.
   */
  bool operator > (const char* Str) const
  {
    return strcmp (GetDataSafe (), Str) > 0;
  }
  /**
   * Check if another string is not equal to this one.
   * \param Str Other string.
   * \return False if they are equal; true if not.
   * \remarks The comparison is case-sensitive.
   */
  bool operator != (const StringBase& Str) const
  { return !Compare (Str); }
  /**
   * Check if another string is not equal to this one.
   * \param Str Other string.
   * \return False if they are equal; true if not.
   * \remarks The comparison is case-sensitive.
   */
  bool operator != (const char* Str) const
  { return !Compare (Str); }

  /**
   * Shift operator.
   * For example:
   * \code
   * s << "Hi " << name << ", see " << foo;
   * \endcode
   */
  template <typename T>
  StringBase &operator << (T const& v)
  { return Append (v); }

  // Specialization which prevents gcc from barfing on strings allocated via
  // CS_ALLOC_STACK_ARRAY().
  StringBase &operator << (char const* v)
  { return Append(v); }

  /**
   * Convert this string to lower-case.
   * \return Reference to itself.
   */
  StringBase& Downcase();
  /**
   * Convert this string to upper-case.
   * \return Reference to itself.
   */
  StringBase& Upcase();

  /**
   * Detach the low-level null-terminated C-string buffer from the String
   * object.
   * \return The low-level null-terminated C-string buffer, or zero if this
   *   string represents a null-pointer.  See the class description for a
   *   discussion about how and when the string will represent a null-pointer.
   * \remarks The caller of this function becomes the owner of the returned
   *   string buffer and is responsible for destroying it via `delete[]' when
   *   no longer needed.
   */
  virtual char* Detach ()
  { char* d = Data; Data = 0; Size = 0; MaxSize = 0; return d; }
  /**
   * GetHash() as expected by the default csHashComputer<> implementation to
   * allow use of Strings as hash keys.
   */
  uint32_t GetHash() const
  {
    //SAT_NOTIMPLEMENTED; //"StringBase::GetHash");
    return 0;
    //  return HashCompute (GetData());
  }
};

/// Concatenate a null-terminated C-string with a StringBase.
inline StringBase operator + (const char* iStr1, const StringBase &iStr2)
{
  return StringBase (iStr1).Append (iStr2);
}

/// Concatenate a StringBase with a null-terminated C-string.
inline StringBase operator + (const StringBase& iStr1, const char* iStr2)
{
  return iStr1.Clone ().Append (iStr2);
}

/**
 * Subclass of StringBase that contains an internal buffer which is faster
 * than the always dynamically allocated buffer of StringBase.
 */
template<int LEN = 36>
class StringFast : public StringBase
{
protected:
  /// Internal buffer; used when capacity fits within LEN bytes.
  char minibuff[LEN];
  /**
   * Amount of minibuff allocated by SetCapacityInternal(); not necessarily
   * same as Size. This is analogous to MaxSize in StringBase. We need it to
   * determine if minibuff was ever used in order to return NULL if not (to
   * emulate the NULL returned by StringBase when no buffer has been
   * allocated). We also use minibuff to emulate GetCapacity(), which is a
   * predicate of several memory management methods, such as ExpandIfNeeded().
   */
  size_t miniused;

  virtual void SetCapacityInternal (size_t NewSize, bool soft)
  {
    if (Data != 0) // If dynamic buffer already allocated, just re-use it.
      StringBase::SetCapacityInternal(NewSize, soft);
    else
    {
      NewSize++; // Plus one for implicit null byte.
      if (NewSize <= LEN)
        miniused = NewSize;
      else
      {
        SAT_ASSERT(MaxSize == 0);
        if (soft)
          NewSize = ComputeNewSize (NewSize);
        Data = new char[NewSize];
        MaxSize = NewSize;
        if (Size == 0)
          Data[0] = '\0';
        else
          memcpy(Data, minibuff, Size + 1);
      }
    }
  }

  virtual char* GetDataMutable ()
  { return (miniused == 0 && Data == 0 ? 0 : (Data != 0 ? Data : minibuff)); }

public:
  /**
   * Create an empty StringFast object.
   */
  StringFast () : StringBase(), miniused(0) { }
  /**
   * Create a StringFast object and reserve space for at least Length
   * characters.
   */
  StringFast (size_t Length) : StringBase(), miniused(0)
  { SetCapacity (Length); }
  /**
   * Copy constructor.
   */
  StringFast (const StringBase& copy) : StringBase (), miniused(0)
  { Append (copy); }
  /**
   * Copy constructor.
   */
  StringFast (const StringFast& copy) : StringBase (), miniused(0)
  { Append (copy); }
  /**
   * Create a StringFast object from a null-terminated C string.
   */
  StringFast (const char* src) : StringBase(), miniused(0)
  { Append (src); }
  /**
   * Create a StringFast object from a C string, given the length.
   */
  StringFast (const char* src, size_t _length) : StringBase(), miniused(0)
  { Append (src, _length); }


  /// Create a StringFast object from a single signed character.
  StringFast (char c) : StringBase(), miniused(0)
  { Append (c); }
  /// Create a StringFast object from a single unsigned character.
  StringFast (unsigned char c) : StringBase(), miniused(0)
  { Append ((char)c); }
  /// Destroy the StringFast.
  virtual ~StringFast () { }

  /// Assign a value to this string.
  const StringFast& operator = (const StringBase& copy)
  { Replace(copy); return *this; }

  /// Assign a formatted value to this string.
  template<typename T>
  const StringFast& operator = (T const& s) { Replace (s); return *this; }

  virtual char const* GetData () const
  { return (miniused == 0 && Data == 0 ? 0 : (Data != 0 ? Data : minibuff)); }

  virtual size_t GetCapacity() const
  { return Data != 0 ? StringBase::GetCapacity() : miniused - 1; }

  virtual void ShrinkBestFit ()
  {
    if (Size == 0)
    {
      StringBase::ShrinkBestFit();
      miniused = 0;
    }
    else
    {
      size_t needed = Size + 1;
      if (needed > LEN)
        StringBase::ShrinkBestFit();
      else
      {
        miniused = needed;
        if (Data != 0)
        {
          memcpy(minibuff, Data, needed); // Includes implicit null byte.
          StringBase::Free();
        }
      }
    }
  }

  virtual void Free () { miniused = 0; StringBase::Free(); }

  virtual char* Detach ()
  {
    if (Data != 0)
      return StringBase::Detach();
    else if (miniused == 0)
      return 0; // Emulate NULL return of StringBase in this case.
    else
    {
      SAT_ASSERT(MaxSize == 0);
      char* d = StrNew (minibuff);
      Size = 0; miniused = 0;
      return d;
    }
  }
};


template<>
class StringFast<0> : public StringBase
{
public:
  StringFast () : StringBase() { }
  StringFast (size_t Length) : StringBase(Length) { }
  StringFast (const StringBase& copy) : StringBase (copy) { }
  StringFast (const char* src) : StringBase(src) { }
  StringFast (const char* src, size_t _length) : StringBase(src, _length)
  { }
  StringFast (char c) : StringBase(c) { }
  StringFast (unsigned char c) : StringBase(c) { }
  const StringFast& operator = (const StringBase& copy)
  { Replace(copy); return *this; }
  const StringFast& operator = (const char* copy)
  { Replace(copy); return *this; }
  const StringFast& operator = (char x)
  { Replace(x); return *this; }
  const StringFast& operator = (unsigned char x)
  { Replace(x); return *this; }
  const StringFast& operator = (bool x)
  { Replace(x); return *this; }
  const StringFast& operator = (short x)
  { Replace(x); return *this; }
  const StringFast& operator = (unsigned short x)
  { Replace(x); return *this; }
  const StringFast& operator = (int x)
  { Replace(x); return *this; }
  const StringFast& operator = (unsigned int x)
  { Replace(x); return *this; }
  const StringFast& operator = (long x)
  { Replace(x); return *this; }
  const StringFast& operator = (unsigned long x)
  { Replace(x); return *this; }
  const StringFast& operator = (float x)
  { Replace(x); return *this; }
  const StringFast& operator = (double x)
  { Replace(x); return *this; }
};

#ifndef SWIG
/**
 * Superclass of String; normally StringFast<>.
 * \internal This is just an implementation detail to pacify Swig which
 *   otherwise complains that it does not know anything about StringFast<>.
 */
typedef StringFast<> StringFastDefault;
#else
#define StringFastDefault StringFast<36>
%template(StringParent) StringFast<36>;
#endif

/**
 * Thin wrapper around StringFast<> with its default buffer size.
 */
class String : public StringFastDefault
{
public:
  /// Create an empty String object.
  String () : StringFast<> () { }
  /**
   * Create a String object and reserve space for at least \p Length
   * characters.
   */
  String (size_t Length) : StringFast<> (Length) { }
  /** @{ */
  /// Copy constructor.
  String (const String& copy) :
    StringFast<> ((const StringBase&)copy) { }
  String (const StringBase& copy) : StringFast<> (copy) { }
  /** @} */
  /// Create a String object from a null-terminated C string.
  String (const char* src) : StringFast<> (src) { }
  /// Create a String object from a C string, given the length.
  String (const char* src, size_t _length) : StringFast<> (src, _length) { }
  /// Create a String object from a single signed character.
  String (char c) : StringFast<> (c) { }
  /// Create a String object from a single unsigned character.
  String (unsigned char c) : StringFast<> (c) { }

  /** @{ */
  /// Assign a value to this string.
  const String& operator = (const String& copy)
  { Replace(copy); return *this; }
  const String& operator = (const StringBase& copy)
  { Replace(copy); return *this; }
  const String& operator = (const char* copy)
  { Replace(copy); return *this; }
  const String& operator = (char x)
  { Replace(x); return *this; }
  const String& operator = (unsigned char x)
  { Replace(x); return *this; }
  const String& operator = (bool x)
  { Replace(x); return *this; }
  const String& operator = (short x)
  { Replace(x); return *this; }
  const String& operator = (unsigned short x)
  { Replace(x); return *this; }
  const String& operator = (int x)
  { Replace(x); return *this; }
  const String& operator = (unsigned int x)
  { Replace(x); return *this; }
  const String& operator = (long x)
  { Replace(x); return *this; }
  const String& operator = (unsigned long x)
  { Replace(x); return *this; }
  const String& operator = (float x)
  { Replace(x); return *this; }
  const String& operator = (double x)
  { Replace(x); return *this; }
  /** @} */
};

/** @} */

#endif //SAT_STRING_H
