/*
    Copyright (C) 1998 by Jorrit Tyberghein

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
 * @file   strutil.h
 * @brief  Helper function to work with char strings
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_STRUTIL_H__
#define __SAT_STRUTIL_H__

#include "base/sys/stdhdrs.h"

/**@addtogroup base_common
 * @{ */

/**
 * Allocate a new char [] and copy the string into the newly allocated
 * storage.
 * This is a handy method for copying strings, in fact it is the C++ analogue
 * of the strdup() function from string.h (strdup() is not present on some
 * platforms). To free the pointer the caller should call delete[].
 */
char *StrNew (const char *s);

/**
 * Perform case-insensitive string comparison. Returns a negative number if \p
 * str1 is less than \p str2, zero if they are equal, or a positive number if
 * \p str1 is greater than \p str2. For best portability, use function rather
 * than strcasecmp() or stricmp().
 */
int StrCaseCmp(char const* str1, char const* str2);

/**
 * Perform case-insensitive string comparison of the first \p n characters of
 * \p str1 and \p str2. Returns a negative number if the n-character prefix of
 * \p str1 is less than \p str2, zero if they are equal, or a positive number
 * if the prefix of \p str1 is greater than \p str2. For best portability, use
 * function rather than strncasecmp() or strnicmp().
 */
int StrNCaseCmp(char const* str1, char const* str2,
  size_t n);

/**
 * Split a pathname into separate path and name.
 */
void SplitPath (const char *iPathName, char *oPath,
  size_t iPathSize, char *oName, size_t iNameSize);

/**
 * Perform shell-like filename \e globbing (pattern matching).
 * The special token \p * matches zero or more characters, and the token \p ?
 * matches exactly one character. Examples: "*a*.txt", "*a?b*", "*"
 * Character-classes \p [a-z] are not understood by this function.
 * \remark If you want case-insensitive comparison, convert \p fName and
 *   \p fMask to upper- or lower-case first.
 */
bool GlobMatches (const char *fName,
	const char *fMask);

/**
 * Given \p src and \p dest, which are already allocated, copy \p source to \p
 * dest.  But, do not copy \p search, instead replace that with \p replace
 * string.  \p max is size in bytes of \p dest.
 */
void ReplaceAll (char *dest, const char *src,
  const char *search, const char *replace, int max);

/** @} */

#endif /* __SAT_STRUTIL_H__ */
