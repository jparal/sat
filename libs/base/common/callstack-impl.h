/*
  Copyright (C) 2005 by Jorrit Tyberghein
            (C) 2005 by Frank Richter

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

#ifndef __SAT_LIBS_CSUTIL_CALLSTACK_H__
#define __SAT_LIBS_CSUTIL_CALLSTACK_H__

#include "callstack.h"
#include "base/common/array.h" // instead the dirty one!!
//#include "csutil/dirtyaccessarray.h"
//#include "csutil/memheap.h"


namespace SAT
{
namespace Debug
{

/**
 * Parameter count signaling that the number and values of the parameters
 * for a callstack entry are unknown.
 */
const size_t csParamUnknown = (size_t)~0;

/// Callstack entryoffset
struct CallStackEntry
{
  /// Instruction pointer
  void* address;
  /// Number of parameters
  size_t paramNum;
  /// Index of first parameter in callstack params
  size_t paramOffs;
};
// typedef csDirtyAccessArray<CallStackEntry,
//   csArrayElementHandler<CallStackEntry>,
//   CS::Memory::AllocatorMallocPlatform> CallStackEntriesArray;

// typedef csDirtyAccessArray<uintptr_t,
//   csArrayElementHandler<uintptr_t>,
//   CS::Memory::AllocatorMallocPlatform> CallStackParamsArray;

typedef Array<CallStackEntry, ArrayElementHandler<CallStackEntry>,
  SAT::Memory::AllocatorMallocPlatform> CallStackEntriesArray;

typedef Array<uintptr_t, ArrayElementHandler<uintptr_t>,
  SAT::Memory::AllocatorMallocPlatform> CallStackParamsArray;

/// Interface for a call stack creator
struct iCallStackCreator
{
protected:
  virtual ~iCallStackCreator() {}
public:
  /// Fill the arrays with call stack information
  virtual bool CreateCallStack (CallStackEntriesArray& entries,
    CallStackParamsArray& params, bool fast) = 0;
};

/// Call stack symbol name resolver
struct iCallStackNameResolver
{
protected:
  virtual ~iCallStackNameResolver() {}
public:
  /**
   * Get textual description of an instruction pointer. The returned string
   * should contain address itself, symbol name, module if possible.
   */
  virtual bool GetAddressSymbol (void* addr, char*& sym) = 0;
  /**
   * Start retrieving names for parameters of the function in which \a addr
   * lies.
   */
  virtual void* OpenParamSymbols (void* addr) = 0;
  /// Get name of a parameter of a function
  virtual bool GetParamName (void* handle, size_t paramNum, char*& sym) = 0;
  /// End retrieving names for parameters.
  virtual void FreeParamSymbols (void* handle) = 0;
  /// Get the file and line number for an instruction pointer.
  virtual bool GetLineNumber (void* addr, char*& lineAndFile) = 0;
};

#include "newdisable.h"

struct CallstackAllocated
{
  SAT_INLINE_ALWAYS void* operator new(size_t s) throw()
  { return malloc (s); }
  SAT_INLINE_ALWAYS void operator delete(void* p) throw()
  { if (p != 0) free (p); }

#if defined(SAT_EXTENSIVE_MEMDEBUG) || defined(SAT_MEMORY_TRACKER)
  SAT_INLINE_ALWAYS void* operator new (size_t s, void* filename, int line)
  { return malloc (s); }
  SAT_INLINE_ALWAYS void operator delete (void* p, void*, int)
  { if (p != 0) free (p); }
#endif
};

template<typename Super>
struct CallstackAllocatedDerived : public Super
{
  SAT_INLINE_ALWAYS void* operator new(size_t s) throw()
  { return malloc (s); }
  SAT_INLINE_ALWAYS void operator delete(void* p) throw()
  { if (p != 0) free (p); }

#if defined(SAT_EXTENSIVE_MEMDEBUG) || defined(SAT_MEMORY_TRACKER)
  SAT_INLINE_ALWAYS void* operator new (size_t s, void* filename, int line)
  { return malloc (s); }
  SAT_INLINE_ALWAYS void operator delete (void* p, void*, int)
  { if (p != 0) free (p); }
#endif
};

#include "newenable.h"

class CallStackImpl : public CallstackAllocatedDerived<CallStack>
{
public:
  CallStackEntriesArray entries;
  CallStackParamsArray params;

  virtual void Free();

  virtual size_t GetEntryCount ();
  virtual bool GetFunctionName (size_t num, char*& str);
  virtual bool GetLineNumber (size_t num, char*& str);
  virtual bool GetParameters (size_t num, char*& str);
};

} // namespace Debug
} // namespace SAT

#endif // __SAT_LIBS_CSUTIL_CALLSTACK_H__
