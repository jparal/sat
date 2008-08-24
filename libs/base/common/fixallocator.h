/*
  Crystal Space Fixed Size Block Allocator
  Copyright (C) 2005 by Eric Sunshine <sunshine@sunshineco.com>
	    (C) 2006 by Frank Richter

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
 * @file   fixallocator.h
 * @brief  Fixed Size Block Allocator
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FIXALLOCATOR_H__
#define __SAT_FIXALLOCATOR_H__

#include "satconfig.h"
#include "base/common/array.h"
#include "base/common/bitarray.h"
// #include "common/sysfunc.h"
#include "allocator.h"

#ifdef SAT_DEBUG
#include <typeinfo>
#endif

/**@addtogroup base_common
 * @{ */

/**
 * This class implements a memory allocator which can efficiently allocate
 * objects that all have the same size. It has no memory overhead per
 * allocation (unless the objects are smaller than sizeof(void*) bytes) and is
 * extremely fast, both for Alloc() and Free(). The only restriction is that
 * any specific allocator can be used for just one type of object (the type for
 * which the template is instantiated).
 *
 * \remarks Defining the macro SAT_FIXEDSIZEALLOC_DEBUG will cause freed
 *   objects to be overwritten with '0xfb' bytes. This can be useful to track
 *   use of already freed objects, as they can be more easily recognized
 *   (as some members will be likely bogus.)
 * \sa Array
 * \sa MemoryPool
 */
template <size_t Size, class Allocator = SAT::Memory::AllocatorMalloc>
class FixedSizeAllocator
{
public:
  typedef FixedSizeAllocator<Size, Allocator> ThisType;
  typedef Allocator AllocatorType;

protected: // 'protected' allows access by test-suite.
  struct FreeNode
  {
    FreeNode* next;
  };

  struct BlockKey
  {
    uint8_t const* addr;
    size_t blocksize;
    BlockKey(uint8_t const* p, size_t n) : addr(p), blocksize(n) {}
  };

  struct BlocksWrapper : public Allocator
  {
    Array<uint8_t*> b;
  };
  /// List of allocated blocks; sorted by address.
  BlocksWrapper blocks;
  /// Number of elements per block.
  size_t elcount;
  /// Element size; >= sizeof(void*).
  size_t elsize;
  /// Size in bytes per block.
  size_t blocksize;
  /// Head of the chain of free nodes.
  FreeNode* freenode;
  /**
   * Flag to ignore calls to Compact() and Free() if they're called recursively
   * while disposing the entire allocation set. Recursive calls to Alloc() will
   * signal an assertion failure.
   */
  bool insideDisposeAll;

  /**
   * Comparison function for FindBlock() which does a "fuzzy" search given an
   * arbitrary address.  It checks if the address falls somewhere within a
   * block rather than checking if the address exactly matches the start of the
   * block (which is the only information recorded in blocks[] array).
   */
  static int FuzzyCmp(uint8_t* const& block, BlockKey const& k)
  {
    return (block + k.blocksize <= k.addr ? -1 : (block > k.addr ? 1 : 0));
  }

  /**
   * Find the memory block which contains the given memory.
   */
  size_t FindBlock(void const* m) const
  {
    return blocks.b.FindSortedKey(
      ArrayCmp<uint8_t*,BlockKey>(BlockKey((uint8_t*)m, blocksize), FuzzyCmp));
  }

  /**
   * Allocate a block and initialize its free-node chain.
   * \return The returned address is both the reference to the overall block,
   *   and the address of the first free node in the chain.
   */
  uint8_t* AllocBlock()
  {
    uint8_t* block = (uint8_t*)blocks.Alloc (blocksize);

    // Build the free-node chain (all nodes are free in the new block).
    FreeNode* nextfree = 0;
    uint8_t* node = block + (elcount - 1) * elsize;
    for ( ; node >= block; node -= elsize)
    {
      FreeNode* slot = (FreeNode*)node;
      slot->next = nextfree;
      nextfree = slot;
    }
    SAT_ASSERT((uint8_t*)nextfree == block);
    return block;
  }

  /**
   * Dispose of a block.
   */
  void FreeBlock(uint8_t* p)
  {
    blocks.Free (p);
  }

  /**
   * Destroy an object.
   */
  template<typename Disposer>
  void DestroyObject (Disposer& disposer, void* p) const
  {
    disposer.Dispose (p);
#ifdef SAT_FIXEDSIZEALLOC_DEBUG
    memset (p, 0xfb, elsize);
#endif
  }

  /**
   * Get a usage mask showing all used (1's) and free (0's) nodes in
   * the entire allocator.
   */
  BitArray GetAllocationMap() const
  {
    BitArray mask(elcount * blocks.b.GetSize());
    mask.FlipAllBits();
    for (FreeNode* p = freenode; p != 0; p = p->next)
    {
      size_t const n = FindBlock(p);
      SAT_ASSERT(n != ArrayItemNotFound);
      size_t const slot = ((uint8_t*)p - blocks.b[n]) / elsize; // Slot in block.
      mask.ClearBit(n * elcount + slot);
    }
    return mask;
  }

  /// Default disposer mixin, just reporting leaks.
  class DefaultDisposer
  {
  #ifdef SAT_DEBUG
    bool doWarn;
    const char* parentClass;
    const void* parent;
    size_t count;
  #endif
  public:
  #ifdef SAT_DEBUG
    template<typename BA>
    DefaultDisposer (const BA& ba, bool legit) :
      doWarn (!legit), parentClass (typeid(BA).name()), parent (&ba),
      count (0)
    {
    }
  #else
    template<typename BA>
    DefaultDisposer (const BA&, bool legit)
    { (void)legit; }
  #endif
    ~DefaultDisposer()
    {
  #ifdef SAT_DEBUG
      if ((count > 0) && doWarn)
      {
        printf ("%s %p leaked %zu objects.\n", parentClass, (void*)this,
          count);
      }
  #endif
    }
    void Dispose (void* /*p*/)
    {
  #ifdef SAT_DEBUG
      count++;
  #endif
    }
  };
  /**
   * Destroys all living objects and releases all memory allocated by the pool.
   * \param disposer Object with a Dispose(void* p) method which is called prior
   *  to freeing the actual memory.
   */
  template<typename Disposer>
  void DisposeAll(Disposer& disposer)
  {
    insideDisposeAll = true;
    BitArray const mask(GetAllocationMap());
    size_t node = 0;
    for (size_t b = 0, bN = blocks.b.GetSize(); b < bN; b++)
    {
      for (uint8_t *p = blocks.b[b], *pN = p + blocksize; p < pN; p += elsize)
        if (mask.IsBitSet(node++))
          DestroyObject (disposer, p);
      FreeBlock(blocks.b[b]);
    }
    blocks.b.DeleteAll();
    freenode = 0;
    insideDisposeAll = false;
  }

  /**
   * Deallocate a chunk of memory. It is safe to provide a null pointer.
   * \param disposer Disposer object that is passed to DestroyObject().
   * \param p Pointer to deallocate.
   */
  template<typename Disposer>
  void Free (Disposer& disposer, void* p)
  {
    if (p != 0 && !insideDisposeAll)
    {
      SAT_ASSERT(FindBlock(p) != ArrayItemNotFound);
      DestroyObject (disposer, p);
      FreeNode* f = (FreeNode*)p;
      f->next = freenode;
      freenode = f;
    }
  }
  /**
   * Try to delete a chunk of memory. Usage is the same as Free(), the
   * difference being that \c false is returned if the deallocation failed
   * (the reason is most likely that the memory was not allocated by the
   * allocator).
   */
  template<typename Disposer>
  bool TryFree (Disposer& disposer, void* p)
  {
    if (p != 0 && !insideDisposeAll)
    {
      if (FindBlock(p) == ArrayItemNotFound) return false;
      DestroyObject (disposer, p);
      FreeNode* f = (FreeNode*)p;
      f->next = freenode;
      freenode = f;
    }
    return true;
  }

  /// Find and allocate a block
  void* AllocCommon ()
  {
    if (insideDisposeAll)
    {
      printf ("ERROR: FixedSizeAllocator(%p) tried to allocate memory "
	"while inside DisposeAll()", (void*)this);
      SAT_ASSERT(false);
    }

    if (freenode == 0)
    {
      uint8_t* p = AllocBlock();
      blocks.b.InsertSorted(p);
      freenode = (FreeNode*)p;
    }
    void* const node = freenode;
    freenode = freenode->next;
    return node;
  }
private:
  FixedSizeAllocator (FixedSizeAllocator const&);  // Illegal; unimplemented.
  void operator= (FixedSizeAllocator const&); 	// Illegal; unimplemented.
public:
  /**
   * Construct a new fixed size allocator.
   * \param nelem Number of elements to store in each allocation unit.
   * \remarks Bigger values for \c nelem will improve allocation performance,
   *   but at the cost of having some potential waste if you do not add
   *   \c nelem elements to each pool.  For instance, if \c nelem is 50 but you
   *   only add 3 elements to the pool, then the space for the remaining 47
   *   elements, though allocated, will remain unused (until you add more
   *   elements).
   */
  FixedSizeAllocator (size_t nelem = 32) :
    elcount (nelem), elsize(Size), freenode(0), insideDisposeAll(false)
  {
#ifdef SAT_MEMORY_TRACKER
    blocks.SetMemTrackerInfo (typeid(*this).name());
#endif
    if (elsize < sizeof (FreeNode))
      elsize = sizeof (FreeNode);
    blocksize = elsize * elcount;
  }

  /**
   * Destroy all allocated objects and release memory.
   */
  ~FixedSizeAllocator()
  {
    DefaultDisposer disposer (*this, false);
    DisposeAll (disposer);
  }

  /**
   * Destroy all chunks allocated.
   * \remarks All pointers returned by Alloc() are invalidated. It is safe to
   *   perform new allocations from the pool after invoking Empty().
   */
  void Empty()
  {
    DefaultDisposer disposer (*this, true);
    DisposeAll (disposer);
  }

  /**
   * Compact the allocator so that all blocks that are completely unused
   * are removed. The blocks that still contain elements are not touched.
   */
  void Compact()
  {
    if (insideDisposeAll) return;

    bool compacted = false;
    BitArray mask(GetAllocationMap());
    for (size_t b = blocks.b.GetSize(); b-- > 0; )
    {
      size_t const node = b * elcount;
      if (!mask.AreSomeBitsSet(node, elcount))
      {
        FreeBlock(blocks.b[b]);
        blocks.b.DeleteIndex(b);
        mask.Delete(node, elcount);
        compacted = true;
      }
    }

    // If blocks were deleted, then free-node chain broke, so rebuild it.
    if (compacted)
    {
      FreeNode* nextfree = 0;
      size_t const bN = blocks.b.GetSize();
      size_t node = bN * elcount;
      for (size_t b = bN; b-- > 0; )
      {
        uint8_t* const p0 = blocks.b[b];
        for (uint8_t* p = p0 + (elcount - 1) * elsize; p >= p0; p -= elsize)
        {
          if (!mask.IsBitSet(--node))
          {
            FreeNode* slot = (FreeNode*)p;
            slot->next = nextfree;
            nextfree = slot;
          }
        }
      }
      freenode = nextfree;
    }
  }

  /**
   * Allocate a chunk of memory.
   */
  void* Alloc ()
  {
    return AllocCommon();
  }

  /**
   * Deallocate a chunk of memory. It is safe to provide a null pointer.
   * \param p Pointer to deallocate.
   */
  void Free (void* p)
  {
    DefaultDisposer disposer (*this, true);
    Free (disposer, p);
  }
  /**
   * Try to delete a chunk of memory. Usage is the same as Free(), the
   * difference being that \c false is returned if the deallocation failed
   * (the reason is most likely that the memory was not allocated by the
   * allocator).
   */
  bool TryFree (void* p)
  {
    DefaultDisposer disposer (*this, true);
    return TryFree (disposer, p);
  }
  /// Query number of elements per block.
  size_t GetBlockElements() const { return elcount; }

  /**\name Functions for useability as a allocator template parameter
   * @{ */
  void* Alloc (size_t n)
  {
    SAT_ASSERT (n == Size);
    return Alloc();
  }
  void* Alloc (void* p, size_t newSize)
  {
    SAT_ASSERT (newSize == Size);
    return p;
  }
  void SetMemTrackerInfo (const char* /*info*/) { }
  /** @} */
};

/** @} */

#endif // __SATUTIL_FIXEDSIZEALLOCATOR_H__
