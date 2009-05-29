/*
  Copyright (C) 2007 by Frank Richter

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef __SAT_BASE_COMMON_CUSTOMALLOCATED_H__
#define __SAT_BASE_COMMON_CUSTOMALLOCATED_H__

#include "newdisable.h"

/**\file
 * Base class to allocate subclasses with malloc().
 */

namespace SAT
{
  namespace Memory
  {
    /**
     * Class that overrides operator new/operator delete/etc.
     * with implementations using malloc()/free().
     * \remarks To outfit a class that also derives from another class with
     *   custom allocation don't use multiple inheritance, use
     *   CustomAllocatedDerived<> instead.
     *
     *   The reason is that the CustomAllocated instance contained in the
     *   derived class may take up some memory (in order to have a distinct
     *   address in memory), memory which is otherwise unused and wasted.
     *   CustomAllocatedDerived<> works around that as it is a base class
     *   and can thus be empty; derivation is supported through templating.
     *   (For details see http://www.cantrip.org/emptyopt.html .)
     */
    class CustomAllocated
    {
    public:
      // Potentially throwing versions
    #ifndef SAT_NO_EXCEPTIONS
      SAT_FORCEINLINE void* operator new (size_t s) throw (std::bad_alloc)
      {
	void* p = malloc (s);
	if (!p) throw std::bad_alloc();
	return p;
      }
      SAT_FORCEINLINE void* operator new[] (size_t s) throw (std::bad_alloc)
      {
	void* p = malloc (s);
	if (!p) throw std::bad_alloc();
	return p;
      }
    #else
      SAT_FORCEINLINE void* operator new (size_t s) throw ()
      { return malloc (s); }
      SAT_FORCEINLINE void* operator new[] (size_t s) throw ()
      { return malloc (s); }
    #endif

      SAT_FORCEINLINE void operator delete (void* p) throw()
      { free (p); }
      SAT_FORCEINLINE void operator delete[] (void* p) throw()
      { free (p); }

      // Nothrow versions
      SAT_FORCEINLINE void* operator new (size_t s, const std::nothrow_t&) throw()
      { return malloc (s); }
      SAT_FORCEINLINE void* operator new[] (size_t s, const std::nothrow_t&) throw()
      { return malloc (s); }
      SAT_FORCEINLINE void operator delete (void* p, const std::nothrow_t&) throw()
      { free (p); }
      SAT_FORCEINLINE void operator delete[] (void* p, const std::nothrow_t&) throw()
      { free (p); }

      // Placement versions
      SAT_FORCEINLINE void* operator new(size_t /*s*/, void* p) throw() { return p; }
      SAT_FORCEINLINE void* operator new[](size_t /*s*/, void* p) throw() { return p; }

      SAT_FORCEINLINE void operator delete(void*, void*) throw() { }
      SAT_FORCEINLINE void operator delete[](void*, void*) throw() { }

    #if defined(SAT_EXTENSIVE_MEMDEBUG) || defined(SAT_MEMORY_TRACKER)
      SAT_FORCEINLINE void* operator new (size_t s, void*, int)
      { return malloc (s); }
      SAT_FORCEINLINE void operator delete (void* p, void*, int)
      { free (p); }
      SAT_FORCEINLINE void* operator new[] (size_t s,  void*, int)
      { return malloc (s); }
      SAT_FORCEINLINE void operator delete[] (void* p, void*, int)
      { free (p); }
    #endif
    };

    /**
     * Class that overrides operator new/operator delete/etc.
     * with implementations using malloc()/free().
     * \remarks Use this class when you want to add custom allocation to a
     *   a class that derives from some other class(es). See the
     *   CustomAllocator remarks section for the explanation.
     */
    template<typename T>
    class CustomAllocatedDerived : public T
    {
    public:
      CustomAllocatedDerived () {}
      template<typename A>
      CustomAllocatedDerived (const A& a) : T (a) {}

      // Potentially throwing versions
    #ifndef SAT_NO_EXCEPTIONS
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new (size_t s) throw (std::bad_alloc)
      {
	void* p = malloc (s);
	if (!p) throw std::bad_alloc();
	return p;
      }
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new[] (size_t s) throw (std::bad_alloc)
      {
	void* p = malloc (s);
	if (!p) throw std::bad_alloc();
	return p;
      }
    #else
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new (size_t s) throw ()
      { return malloc (s); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new[] (size_t s) throw ()
      { return malloc (s); }
    #endif

      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete (void* p) throw()
      { free (p); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete[] (void* p) throw()
      { free (p); }

      // Nothrow versions
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new (size_t s, const std::nothrow_t&) throw()
      { return malloc (s); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new[] (size_t s, const std::nothrow_t&) throw()
      { return malloc (s); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete (void* p, const std::nothrow_t&) throw()
      { free (p); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete[] (void* p, const std::nothrow_t&) throw()
      { free (p); }

      // Placement versions
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new(size_t /*s*/, void* p) throw() { return p; }
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new[](size_t /*s*/, void* p) throw() { return p; }

      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete(void*, void*) throw() { }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete[](void*, void*) throw() { }

    #if defined(SAT_EXTENSIVE_MEMDEBUG) || defined(SAT_MEMORY_TRACKER)
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new (size_t s, void*, int)
      { return malloc (s); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete (void* p, void*, int)
      { free (p); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void* operator new[] (size_t s,  void*, int)
      { return malloc (s); }
      SAT_FORCEINLINE_TEMPLATEMETHOD void operator delete[] (void* p, void*, int)
      { free (p); }
    #endif
    };
  } // namespace Memory
} // namespace SAT

#include "newenable.h"

#endif // __SAT_BASE_COMMON_CUSTOMALLOCATED_H__
