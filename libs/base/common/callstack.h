/*
  Call stack creation helper
  Copyright (C) 2004 by Jorrit Tyberghein
	    (C) 2004 by Frank Richter

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

#ifndef __SAT_UTIL_CALLSTACK_H__
#define __SAT_UTIL_CALLSTACK_H__

/// @file
/// Call stack creation helper

#include "base/common/string.h"

/// Avoid using RefCount, which uses the ref tracker, which in turn uses
/// CallStack Call stack.
class CallStack
{
protected:
  int ref_count;

  virtual ~CallStack() {}
public:
  CallStack () : ref_count (1) { }

  void IncRef () { ref_count++; }
  void DecRef ()
  {
    ref_count--;
    if (ref_count <= 0)
      Free ();
  }
  int GetRefCount () const { return ref_count; }

  /**
   * Release the memory for this call stack.
   */
  virtual void Free() = 0;

  /// Get number of entries in the stack.
  virtual size_t GetEntryCount () = 0;
  //{@
  /**
   * Get the function for an entry.
   * Contains usually raw address, function name and module name.
   * Returns false if an error occured or a name is not available.
   */
  virtual bool GetFunctionName (size_t num, char*& str) = 0;
  bool GetFunctionName (size_t num, String& str)
  {
    char* cstr;
    if (GetFunctionName (num, cstr))
    {
      str = cstr;
      free (cstr);
      return true;
    }
    return false;
  }
  //@}

  //{@
  /**
   * Get file and line number for an entry.
   * Returns false if an error occured or a line number is not
   * available.
   */
  virtual bool GetLineNumber (size_t num, char*& str) = 0;
  bool GetLineNumber (size_t num, String& str)
  {
    char* cstr;
    if (GetLineNumber (num, cstr))
    {
      str = cstr;
      free (cstr);
      return true;
    }
    return false;
  }
  //@}
  //{@
  /**
   * Get function parameter names and values.
   * Returns false if an error occured or if parameters are not available.
   */
  virtual bool GetParameters (size_t num, char*& str) = 0;
  bool GetParameters (size_t num, String& str)
  {
    char* cstr;
    if (GetParameters (num, cstr))
    {
      str = cstr;
      free (cstr);
      return true;
    }
    return false;
  }
  //@}
  /**
   * Print the complete stack.
   * @param f File handle to print to.
   * @param brief Brief output - line number and parameters are omitted.
   */
  void Print (FILE* f = stdout, bool brief = false)
  {
    for (size_t i = 0; i < GetEntryCount(); i++)
    {
      char* s;
      bool hasFunc = GetFunctionName (i, s);
      fprintf (f, "%s", hasFunc ? (const char*)s : "<unknown>");
      if (hasFunc) free (s);
      if (!brief && (GetLineNumber (i, s)))
      {
	fprintf (f, " @%s", (const char*)s);
	free (s);
      }
      if (!brief && (GetParameters (i, s)))
      {
	fprintf (f, " (%s)", (const char*)s);
	free (s);
      }
      fprintf (f, "\n");
    }
    fflush (f);
  }
  /**
   * Obtain complete text for an entry.
   * @param i Index of the entry.
   * @param brief Brief - line number and parameters are omitted.
   */
  String GetEntryAll (size_t i, bool brief = false)
  {
    String line;
    char* s;
    bool hasFunc = GetFunctionName (i, s);
    line << (hasFunc ? (const char*)s : "<unknown>");
    if (hasFunc) free (s);
    if (!brief && GetLineNumber (i, s))
    {
      line << " @" << s;
      free (s);
    }
    if (!brief && GetParameters (i, s))
    {
      line << " (" << s << ")";
      free (s);
    }
    return line;
  }
};

/// Helper to create a call stack.
class CallStackHelper
{
public:
  /**
   * Create a call stack.
   * @param skip The number of calls on the top of the stack to remove from
   *  the returned call stack. This can be used if e.g. the call stack is
   *  created from some helper function and the helper function itself should
   *  not appear in the stack.
   * @param fast Flag whether a fast call stack creation should be preferred
   *  (usually at the expense of retrieved information).
   * @return A call stack object.
   * @remarks Free the returned object with its Free() method.
   */
  static CallStack* CreateCallStack (int skip = 0, bool fast = false);
};

#endif // __SAT_UTIL_CALLSTACK_H__
