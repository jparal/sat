/*
    Copyright (C) 2006-2007 by Frank Richter

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
 * @file   allocator.h
 * @brief  Basic allocator classes.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ALLOCATOR_H__
#define __SAT_ALLOCATOR_H__

#include "satconfig.h"
#include "base/satsys.h"
#include "alignedalloc.h"
#if defined(SAT_MEMORY_TRACKER)
#  include "memdebug.h"
#  include <typeinfo>
#endif

#define SAT_NO_PTMALLOC

/// @addtogroup base_sys
/// @{

namespace SAT
{
  namespace Memory
  {
    /**\page Allocators Memory allocators
     * Several Crystal Space utility classes take optional memory allocators
     * (e.g. Array<>). This allows clients to customize the memory
     * allocation strategy used in a particular case.

     * For example, if you know that an array has a size below a certain
     * threshold most of the time, you could utilize a LocalBufferAllocator<>
     * which return memory from a fast local buffer, if possible - this is
     * faster than using the heap.
     *
     * As another example, when memory allocations follow a pattern where
     * long-lived allocations are mixed with very short-lived allocations,
     * heap fragmentation can occur when the short-lived allocations are
     * freed. In that case it's beneficial to use a separate heap for the
     * short-lived allocations; specific objects can use that heap via the
     * allocator customization.
     *
     * Allocators must obey the following methods and their semantics:
     * - <tt>void* Alloc(const size_t n)</tt> allocates \a n bytes of memory.
     *   Returns 0 if allocation fails.
     * - <tt>void Free (void* p)</tt> frees the pointer \a p. For debugging
     *   purposes it's usually a good idea to throw an assertion when \a p is
     *   invalid for an allocator.
     * - <tt>void* Realloc (void* p, size_t newSize)</tt> "resizes" the block
     *   at \a p to have a size of \a newSize bytes. If \a p is 0 then the call
     *   should have the same effect as an Alloc() with the specified size.
     *   Be aware that the returned pointer may be different from \a p! Also,
     *   if the reallocation fails, 0 is returned - however, the original
     *   memory block is still valid!
     * - <tt>void SetMemTrackerInfo (const char* info)</tt> is a debugging
     *   aid. If the allocator does memory tracking, some users will call
     *   this method to set a description of themselves which is displayed
     *   to allow easy identification of what object allocated how much
     *   memory. Implementation of this method is entirely optional and can be
     *   safely stubbed out.
     */

    /**
     * A default memory allocator that allocates with malloc ().
     */
    class AllocatorMalloc
    {
#ifdef SAT_MEMORY_TRACKER
      /// Memory tracking info
      const char* mti;
#endif
    public:
#ifdef SAT_MEMORY_TRACKER
      AllocatorMalloc() : mti (0) {}
#endif
      /// Allocate a block of memory of size \p n.
      void* Alloc (const size_t n) SAT_ATTR_MALLOC
      {
#ifdef SAT_MEMORY_TRACKER
	size_t* p = (size_t*)malloc (n);
	if (mti) SAT::Debug::MemTracker::RegisterAlloc (p, n, mti);
	return p;
#else
	return malloc (n);
#endif
      }
      /// Free the block \p p.
      void Free (void* p)
      {
      #ifdef SAT_MEMORY_TRACKER
	SAT::Debug::MemTracker::RegisterFree (p);
      #endif
	free (p);
      }
      /// Resize the allocated block \p p to size \p newSize.
      void* Realloc (void* p, size_t newSize)
      {
#ifdef SAT_MEMORY_TRACKER
        if (p == 0) return Alloc (newSize);
	size_t* np = (size_t*)realloc (p, newSize);
	SAT::Debug::MemTracker::UpdateSize (p, np, newSize);
	return np;
      #else
	return realloc (p, newSize);
      #endif
      }
      /// Set the information used for memory tracking.
      void SetMemTrackerInfo (const char* info)
      {
      #ifdef SAT_MEMORY_TRACKER
	mti = info;
      #else
	(void)info;
      #endif
      }
    };

    /**
     * An allocator with a small local buffer.
     * If the data fits into the local buffer (which is set up to holds
     * @c N elements of type @c T), a memory allocation from the heap is saved.
     * Thus, if you have lots of arrays with a relatively small, well known size
     * you can gain some performance by using this allocator.
     * @c SingleAllocation specifies whether no more than a single block is
     * allocated from the allocator at any time. Using that option saves
     * (albeit a miniscule amount of) memory, but obviously is only safe when
     * it's know that the single allocation constraint is satisfied (such as
     * allocators for csArray<>s).
     *
     * @warning The pointer returned may point into the instance data; be
     *  careful when moving that around - an earlier allocated pointer may
     *  suddenly become invalid!
     * @remark This means that if you use this allocator with an array, and you
     *  nest that into another array, you MUST use
     *  csSafeCopyArrayElementHandler for  the nesting array!
     */
    template<typename T, size_t N, class ExcessAllocator = AllocatorMalloc,
      bool SingleAllocation = false>
    class LocalBufferAllocator : public ExcessAllocator
    {
    #ifdef SAT_DEBUG
      void* startThis;
    #endif
      static const size_t localSize = N * sizeof (T);
      static const uint8_t freePattern = 0xfa;
      static const uint8_t newlyAllocatedSalt = 0xac;
      uint8_t localBuf[localSize + (SingleAllocation ? 0 : 1)];
    public:
      LocalBufferAllocator ()
      {
        if (SingleAllocation)
        {
      #ifdef SAT_DEBUG
          memset (localBuf, freePattern, localSize);
      #endif
        }
        else
          localBuf[localSize] = 0;
      #ifdef SAT_DEBUG
        startThis = this;
      #endif
      }
      LocalBufferAllocator (const ExcessAllocator& xalloc) :
        ExcessAllocator (xalloc)
      {
        if (SingleAllocation)
        {
      #ifdef SAT_DEBUG
          memset (localBuf, freePattern, localSize);
      #endif
        }
        else
          localBuf[localSize] = 0;
      #ifdef SAT_DEBUG
        startThis = this;
      #endif
      }
      T* Alloc (size_t allocSize)
      {
        SAT_DBG_ASSERT(startThis == this);
        if (SingleAllocation)
        {
      #ifdef SAT_DEBUG
          /* Verify that the local buffer consists entirely of the "local
             buffer unallocated" pattern. (Not 100% safe since a valid
             allocated buffer may be coincidentally filled with just that
             pattern, but let's just assume that it's unlikely.) */
          bool validPattern = true;
          for (size_t n = 0; n < localSize; n++)
          {
            if (localBuf[n] != freePattern)
            {
              validPattern = false;
              break;
            }
          }
          SAT_ASSERT_MSG(validPattern, "This LocalBufferAllocator only allows one allocation "
			 "a time!");
          memset (localBuf, newlyAllocatedSalt, localSize);
      #endif
	  if (allocSize <= localSize)
	    return (T*)localBuf;
	  else
          {
            void* p = ExcessAllocator::Alloc (allocSize);
	    return (T*)p;
          }
        }
        else
        {
          void* p;
	  if ((allocSize <= localSize) && !localBuf[localSize])
          {
            localBuf[localSize] = 1;
	    p = localBuf;
        #ifdef SAT_DEBUG
            memset (p, newlyAllocatedSalt, allocSize);
        #endif
          }
	  else
          {
            p = ExcessAllocator::Alloc (allocSize);
          }
          return (T*)p;
        }
      }

      void Free (T* mem)
      {
        SAT_DBG_ASSERT(startThis == this);
        if (SingleAllocation)
        {
          if (mem != (T*)localBuf)
	    ExcessAllocator::Free (mem);
	  else
	  {
      #ifdef SAT_DEBUG
	    /* Verify that the local buffer does entirely consist of the "local
	       buffer unallocated" pattern. (Not 100% safe since a valid
	       allocated buffer may be coincidentally filled with just that
	       pattern, but let's just assume that it's unlikely.) */
	    bool validPattern = true;
	    for (size_t n = 0; n < localSize; n++)
	    {
	      if (localBuf[n] != freePattern)
	      {
		validPattern = false;
		break;
	      }
	    }
	    SAT_ASSERT_MSG(!validPattern, "Free() without prior allocation");
      #endif
	  }
      #ifdef SAT_DEBUG
	  memset (localBuf, freePattern, localSize);
      #endif
        }
        else
        {
          if (mem != (T*)localBuf)
            ExcessAllocator::Free (mem);
          else
          {
            localBuf[localSize] = 0;
          }
        }
      }

      // The 'relevantcount' parameter should be the number of items
      // in the old array that are initialized.
      void* Realloc (void* p, size_t newSize)
      {
        SAT_DBG_ASSERT(startThis == this);
        if (p == 0) return Alloc (newSize);
        if (p == localBuf)
        {
          if (newSize <= localSize)
            return p;
          else
          {
	    p = ExcessAllocator::Alloc (newSize);
	    memcpy (p, localBuf, localSize);
        #ifdef SAT_DEBUG
            memset (localBuf, freePattern, localSize);
        #endif
            if (!SingleAllocation) localBuf[localSize] = 0;
	    return p;
          }
        }
        else
        {
          if ((newSize <= localSize) && !localBuf[localSize])
	  {
	    memcpy (localBuf, p, newSize);
	    ExcessAllocator::Free (p);
            if (!SingleAllocation) localBuf[localSize] = 1;
	    return localBuf;
	  }
	  else
	    return ExcessAllocator::Realloc (p, newSize);
        }
      }

      using ExcessAllocator::SetMemTrackerInfo;
    };

    /**
     * This class implements an allocator policy which aligns the first
     * element on given byte boundary.  It has a per-block overhead of
     * `sizeof(void*)+alignment' bytes.
     */
    template <size_t A = 1>
    class AllocatorAlign
    {
    public:
      /**
       * Allocate a raw block of given size.
       */
      static inline SAT_ATTR_MALLOC void* Alloc (size_t size)
      {
        return AlignedMalloc (size, A);
      }

      /**
       * Free a block.
       * @remarks Does not check that the block pointer is valid.
       */
      static inline void Free (void* p)
      {
        AlignedFree (p);
      }

      void* Realloc (void* p, size_t newSize)
      {
        return AlignedRealloc (p, newSize, A);
      }

      void SetMemTrackerInfo (const char* info)
      {
	(void)info;
      }
    };

    /**
     * A default memory allocator that allocates using new char[].
     * @c Reallocatable specifies whether Realloc() should be supported.
     * (This support incurs an overhead as the allocated size has to be stored.)
     */
    template<bool Reallocatable = true>
    class AllocatorNewChar
    {
    #ifdef SAT_MEMORY_TRACKER
      /// Memory tracking info
      const char* mti;
    #endif
    public:
    #ifdef SAT_MEMORY_TRACKER
      AllocatorNewChar() : mti (0) {}
    #endif
      /// Allocate a block of memory of size \p n.
      SAT_ATTR_MALLOC void* Alloc (const size_t n)
      {
        if (!Reallocatable)
        {
          char* p = new char[n];
      #ifdef SAT_MEMORY_TRACKER
          if (mti) SAT::Debug::MemTracker::RegisterAlloc (p, n, mti);
      #endif
          return p;
        }
	size_t* p = (size_t*)new char[n + sizeof (size_t)];
	*p = n;
	p++;
      #ifdef SAT_MEMORY_TRACKER
	if (mti) SAT::Debug::MemTracker::RegisterAlloc (p, n, mti);
      #endif
	return p;
      }
      /// Free the block \p p.
      void Free (void* p)
      {
      #ifdef SAT_MEMORY_TRACKER
        SAT::Debug::MemTracker::RegisterFree (p);
      #endif
        if (!Reallocatable)
        {
          delete[] (char*)p;
          return;
        }
	size_t* x = (size_t*)p;
	x--;
	delete[] (char*)x;
      }
      /// Resize the allocated block \p p to size \p newSize.
      void* Realloc (void* p, size_t newSize)
      {
        if (!Reallocatable) return 0;

        if (p == 0) return Alloc (newSize);
	size_t* x = (size_t*)p;
	x--;
        size_t oldSize = *x;
	size_t* np = (size_t*)Alloc (newSize);
        if (newSize < oldSize)
          memcpy (np, p, newSize);
        else
          memcpy (np, p, oldSize);
        Free (p);
      #ifdef SAT_MEMORY_TRACKER
	if (mti) SAT::Debug::MemTracker::UpdateSize (p, np, newSize);
      #endif
	return np;
      }
      /// Set the information used for memory tracking.
      void SetMemTrackerInfo (const char* info)
      {
      #ifdef SAT_MEMORY_TRACKER
        if (!Reallocatable) return;
	mti = info;
      #else
	(void)info;
      #endif
      }
    };

    /**
     * A default memory allocator that allocates using new T[].
     * @warning Using this allocator is somewhat dangerous, as an array
     *   of Ts to fit the requested size is allocated, and the array is
     *   casted to a void*. Using anything but POD types is irresponsible.
     *   Don't use this allocator unless you really, @em really have to - for
     *   example, when memory is passed from/to code which uses
     *   new[]/delete[] of T for allocation/deallocation.
     * @remarks Reallocatability is inherently unsupported.
     */
    template<typename T>
    class AllocatorNew
    {
    public:
      /// Allocate a block of memory of size \p n.
      SAT_ATTR_MALLOC void* Alloc (const size_t n)
      {
        return new T[((n + sizeof(T) - 1) / sizeof(T)) * sizeof(T)];
      }
      /// Free the block \p p.
      void Free (void* p)
      {
        delete[] (T*)p;
      }
      /// Resize the allocated block \p p to size \p newSize.
      void* Realloc (void* p, size_t newSize)
      {
        SAT_ASSERT_MSG("Realloc() called on AllocatorNew", false);
	return 0;
      }
      /// Set the information used for memory tracking.
      void SetMemTrackerInfo (const char* /*info*/)
      {
      }
    };


    /**
     * Class to store a pointer that is allocated from Allocator,
     * to eliminate overhead from a possibly empty Allocator.
     * See http://www.cantrip.org/emptyopt.html for details.
     */
    template<typename T, typename Allocator>
    struct AllocatorPointerWrapper : public Allocator
    {
      /// The allocated pointer.
      T* p;

      AllocatorPointerWrapper () {}
      AllocatorPointerWrapper (const Allocator& alloc) :
        Allocator (alloc) {}
      AllocatorPointerWrapper (T* p) : p (p) {}
      AllocatorPointerWrapper (const Allocator& alloc, T* p) :
        Allocator (alloc), p (p) {}
    };

    /**
     * Memory allocator using the platform's default allocation functions
     * (malloc, free etc.)
     */
    class AllocatorMallocPlatform
    {
    public:
      /// Allocate a block of memory of size \p n.
      SAT_ATTR_MALLOC void* Alloc (const size_t n)
      {
	return malloc (n);
      }
      /// Free the block \p p.
      void Free (void* p)
      {
	free (p);
      }
      /// Resize the allocated block \p p to size \p newSize.
      void* Realloc (void* p, size_t newSize)
      {
	return realloc (p, newSize);
      }
      /// Set the information used for memory tracking.
      void SetMemTrackerInfo (const char* info)
      {
	(void)info;
      }
    };
  } // namespace Memory
} // namespace SAT

/// @}

#endif // __SAT_SATUTIL_ALLOCATOR_H__
