/*
    Copyright (C) 2000 by Andrew Kirmse

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
// A one-dimensional array of bits, similar to STL bitset.
//
// Copyright 2000 Andrew Kirmse.  All rights reserved.
//
// Permission is granted to use this code for any purpose, as long as this
// copyright message remains intact.
/**
 * @file   bitarray.h
 * @brief  A one-dimensional array of bits, similar to STL bitset.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_BITARRAY_H__
#define __SAT_BITARRAY_H__

#include "base/satsys.h"

#include "macros.h"
#include "comparator.h"
#include "hash.h"

typedef uint64_t BitArrayStorageType;

const size_t BitArrayDefaultInlineBits =
  sizeof (BitArrayStorageType) * 8;

/// Base comparator for bit arrays
template<typename BitArray>
class ComparatorBitArray
{
public:
  static int Compare (BitArray const& key1, BitArray const& key2)
  {
    BitArrayStorageType const* p0 = key1.GetStore();
    BitArrayStorageType const* p1 = key2.GetStore();
    size_t compareNum = MIN (key1.mLength, key2.mLength);
    size_t i = 0;
    for (; i < compareNum; i++)
      if (p0[i] != p1[i])
	return (int)p0[i] - (int)p1[i];
    if (key1.mLength > key2.mLength)
    {
      for (; i < key1.mLength; i++)
	if (p0[i] != 0)
	  return (int)p0[i];
    }
    else
    {
      for (; i < key2.mLength; i++)
	if (p1[i] != 0)
	  return -((int)p1[i]);
    }
    return 0;
  }
};


/// Base hash computer for bit arrays
template<typename BitArray>
class HashComputerBitArray
{
public:
  static uint ComputeHash (BitArray const& key)
  {
    const size_t uintCount = sizeof (BitArrayStorageType) / sizeof (uint);
    uint ui[uintCount];
    uint hash = 0;
    BitArrayStorageType const* p = key.GetStore();
    // \todo Not very good. Find a better hash function; however, it should
    // return the same hash for two bit arrays that are the same except for
    // the amount of trailing zeros. (e.g. f(10010110) == f(100101100000...))
    for (size_t i = 0; i < key.mLength; i++)
    {
      memcpy (ui, &p[i], sizeof (ui));
      for (size_t j = 0; j < uintCount; j++)
	hash += ui[j];
    }
    return hash;
  }
};

/**
 * A one-dimensional array of bits, similar to STL bitset.
 * The amount of bits is dynamic at runtime.
 *
 * Internally, bits are stored in multiple values of the type
 * BitArrayStorageType. If the number of bits is below a certain threshold,
 * the bits are stored in a field inside the class for more performance,
 * above that threshold, the data is stored on the heap.
 *
 * This threshold can be tweaked by changing the \a InlinedBits template
 * parameter. At least \a InlinedBits bits will be stored inlined in the
 * class (the actual amount is the next bigger multiple of the number of bits
 * fitting into one BitArrayStorageType). In scenarios where you can
 * anticipate that the common number of stored bits is larger than the
 * default number, you can tweak InlinedBits to gain more performance.
 *
 * The \a Allocator template allocator allows you to override the logic
 * to allocate bits from the heap.
 */
template<int InlinedBits = BitArrayDefaultInlineBits,
  typename Allocator = SAT::Memory::AllocatorMalloc>
class BitArrayTweakable
{
public:
  typedef BitArrayTweakable<InlinedBits, Allocator> ThisType;
  typedef Allocator AllocatorType;

private:
  template<typename BitArray> friend class ComparatorBitArray;
  template<typename BitArray> friend class HashComputerBitArray;

  enum
  {
    cellSize    = BitArrayDefaultInlineBits,
    cellCount   = (InlinedBits + (cellSize-1)) / cellSize
  };

  struct Storage : public Allocator
  {
    union
    {
      BitArrayStorageType* heapStore;
      BitArrayStorageType inlineStore[cellCount];
    };
    Storage()
    {
      memset (&inlineStore, 0,
        MAX(sizeof (heapStore), sizeof (inlineStore)));
    }
  };
  Storage storage;
  /// Length of heapStore/inlineStore in units of BitArrayStorageType
  size_t mLength;
  size_t mNumBits;

  /// Get the GetStore()[] index for a given bit number.
  static size_t GetIndex (size_t bit_num)
  {
    return bit_num / (size_t)cellSize;
  }

  /// Get the offset within GetStore()[GetIndex()] for a given bit number.
  static size_t GetOffset (size_t bit_num)
  {
    return bit_num % cellSize;
  }

  /// Return whether the inline or heap store is used
  bool UseInlineStore () const
  {
    return mLength <= cellCount;
  }

  /**
   * Get a constant pointer to bit store, which may be internal mSingleWord or
   * heap-allocated mpStore.
   */
  BitArrayStorageType const* GetStore() const
  {
    return UseInlineStore () ? storage.inlineStore : storage.heapStore;
  }

  /**
   * Get a non-constant pointer to bit store, which may be internal mSingleWord
   * or heap-allocated mpStore.
   */
  BitArrayStorageType* GetStore()
  {
    return UseInlineStore () ? storage.inlineStore : storage.heapStore;
  }

  /// Force overhang bits at the end to 0.
  void Trim()
  {
    size_t extra_bits = mNumBits % cellSize;
    if (mLength > 0 && extra_bits != 0)
      GetStore()[mLength - 1] &= ~((~(BitArrayStorageType)0) << extra_bits);
  }

public:
  /**
   * \internal Bit proxy (for BitArray::operator[])
   */
  class BitProxy
  {
  private:
    BitArrayTweakable& mArray;
    size_t mPos;
  public:
    /// Constructor.
    BitProxy (BitArrayTweakable& array, size_t pos): mArray(array), mPos(pos)
    {}

    /// Boolean assignment.
    BitProxy &operator= (bool value)
    {
      mArray.Set (mPos, value);
      return *this;
    }

    /// Proxy assignment.
    BitProxy &operator= (const BitProxy &that)
    {
      mArray.Set (mPos, that.mArray.IsBitSet (that.mPos));
      return *this;
    }

    /// Boolean accessor.
    operator bool() const
    {
      return mArray.IsBitSet (mPos);
    }

    /**
     * Flip state of this bit.
     * @return New state of bit.
     */
    bool Flip()
    {
      mArray.FlipBit (mPos);
      return mArray.IsBitSet (mPos);
    }
  };
  friend class BitProxy;

  /**
   * Default constructor.
   */
  BitArrayTweakable () : mLength(0), mNumBits(0)
  {
    SetSize (0);
  }

  /**
   * Construct with a size of \a size bits.
   */
  explicit BitArrayTweakable (size_t size) : mLength(0), mNumBits(0)
  {
    SetSize (size);
  }

  /**
   * Construct as duplicate of \a that (copy constructor).
   */
  BitArrayTweakable (const BitArrayTweakable& that) : mLength(0), mNumBits(0)
  {
    *this = that; // Invokes this->operator=().
  }

  /// Destructor.
  ~BitArrayTweakable()
  {
    if (!UseInlineStore ())
      storage.Free (storage.heapStore);
  }

  /// Return the number of stored bits.
  size_t GetSize() const
  {
    return mNumBits;
  }

  /**
   * Return the number of stored bits.
   * \deprecated Use GetSize() instead.
   */
  /*SAT_DEPRECATED_METHOD_MSG("Use GetSize() instead.")*/
  size_t Length () const
  {
    return GetSize();
  }

  /**
   * Set the number of stored bits.
   * \deprecated Use SetSize() instead.
   */
  /*SAT_DEPRECATED_METHOD_MSG("Use SetSize() instead.")*/
  void SetLength (size_t newSize)
  {
    SetSize (newSize);
  }

  /**
   * Set the number of stored bits.
   * @remarks If the new size is larger than the old size, the newly added
   *    bits are cleared.
   */
  void SetSize (size_t newSize)
  {
    size_t newLength;
    if (newSize == 0)
      newLength = 0;
    else
      newLength = 1 + GetIndex (newSize - 1);

    if (newLength != mLength)
    {
      // Avoid allocation if length is 1 (common case)
      BitArrayStorageType* newStore;
      if (newLength <= cellCount)
        newStore = storage.inlineStore;
      else
	newStore = (BitArrayStorageType*)storage.Alloc (
          newLength * sizeof (BitArrayStorageType));

      if (newLength > 0)
      {
	if (mLength > 0)
	{
	  BitArrayStorageType* oldStore = GetStore();
	  if (newStore != oldStore)
	  {
	    memcpy (newStore, oldStore,
	      (MIN (mLength, newLength)) * sizeof (BitArrayStorageType));
	    if (newLength > mLength)
	      memset(newStore + mLength, 0,
		     (newLength - mLength) * sizeof (BitArrayStorageType));
            if (!UseInlineStore ())
              storage.Free (oldStore);
	  }
	}
	else
	  memset (newStore, 0, newLength * sizeof (BitArrayStorageType));
      }
      mLength = newLength;
      if (!UseInlineStore()) storage.heapStore = newStore;
    }

    mNumBits = newSize;
    Trim();
  }

  //
  // Operators
  //

  /// Copy from other array.
  BitArrayTweakable& operator=(const BitArrayTweakable& that)
  {
    if (this != &that)
    {
      SetSize (that.mNumBits);
      memcpy (GetStore(), that.GetStore(),
        mLength * sizeof (BitArrayStorageType));
    }
    return *this;
  }

  /// Return bit at position \a pos.
  BitProxy operator[] (size_t pos)
  {
    SAT_ASSERT (pos < mNumBits);
    return BitProxy(*this, pos);
  }

  /// Return bit at position \a pos.
  bool operator[] (size_t pos) const
  {
    return IsBitSet(pos);
  }

  /// Equal to other array?
  bool operator==(const BitArrayTweakable& that) const
  {
    if (mNumBits != that.mNumBits)
      return false;

    BitArrayStorageType const* p0 = GetStore();
    BitArrayStorageType const* p1 = that.GetStore();
    for (unsigned i = 0; i < mLength; i++)
      if (p0[i] != p1[i])
        return false;
    return true;
  }

  /// Not equal to other array?
  bool operator != (const BitArrayTweakable& that) const
  {
    return !(*this == that);
  }

  /// Bit-wise `and'. The arrays must be the same length.
  BitArrayTweakable& operator &= (const BitArrayTweakable &that)
  {
    SAT_ASSERT (mNumBits == that.mNumBits);
    BitArrayStorageType* p0 = GetStore();
    BitArrayStorageType const* p1 = that.GetStore();
    for (size_t i = 0; i < mLength; i++)
      p0[i] &= p1[i];
    return *this;
  }

  /// Bit-wise `or'. The arrays must be the same length.
  BitArrayTweakable operator |= (const BitArrayTweakable& that)
  {
    SAT_ASSERT (mNumBits == that.mNumBits);
    BitArrayStorageType* p0 = GetStore();
    BitArrayStorageType const* p1 = that.GetStore();
    for (size_t i = 0; i < mLength; i++)
      p0[i] |= p1[i];
    return *this;
  }

  /// Bit-wise `xor'. The arrays must be the same length.
  BitArrayTweakable operator ^= (const BitArrayTweakable& that)
  {
    SAT_ASSERT (mNumBits == that.mNumBits);
    BitArrayStorageType* p0 = GetStore();
    BitArrayStorageType const* p1 = that.GetStore();
    for (size_t i = 0; i < mLength; i++)
      p0[i] ^= p1[i];
    return *this;
  }

  /// Return complement bit array in which all bits are flipped from this one.
  BitArrayTweakable operator~() const
  {
    return BitArrayTweakable(*this).FlipAllBits();
  }

  /// Bit-wise `and'. The arrays must be the same length.
  friend BitArrayTweakable operator& (const BitArrayTweakable& a1,
    const BitArrayTweakable& a2)
  {
    return BitArrayTweakable (a1) &= a2;
  }

  /// Bit-wise `or'. The arrays must be the same length.
  friend BitArrayTweakable operator | (const BitArrayTweakable& a1,
    const BitArrayTweakable& a2)
  {
    return BitArrayTweakable (a1) |= a2;
  }

  /// Bit-wise `xor'. The arrays must be the same length.
  friend BitArrayTweakable operator ^ (const BitArrayTweakable& a1,
    const BitArrayTweakable& a2)
  {
    return BitArrayTweakable (a1) ^= a2;
  }

  //
  // Plain English interface
  //

  /// Set all bits to false.
  void Clear()
  {
    memset (GetStore(), 0, mLength * sizeof(BitArrayStorageType));
  }

  /// Set the bit at position pos to true.
  void SetBit (size_t pos)
  {
    SAT_ASSERT (pos < mNumBits);
    GetStore()[GetIndex(pos)] |= ((BitArrayStorageType)1) << GetOffset(pos);
  }

  /// Set the bit at position pos to false.
  void ClearBit (size_t pos)
  {
    SAT_ASSERT (pos < mNumBits);
    GetStore()[GetIndex(pos)] &= ~(((BitArrayStorageType)1) << GetOffset(pos));
  }

  /// Toggle the bit at position pos.
  void FlipBit (size_t pos)
  {
    SAT_ASSERT (pos < mNumBits);
    GetStore()[GetIndex(pos)] ^= ((BitArrayStorageType)1) << GetOffset(pos);
  }

  /// Set the bit at position \a pos to the given value.
  void Set (size_t pos, bool val = true)
  {
    if (val)
      SetBit(pos);
    else
      ClearBit(pos);
  }

  /// Returns true if the bit at position \a pos is true.
  bool IsBitSet (size_t pos) const
  {
    SAT_ASSERT (pos < mNumBits);
    return (GetStore()[GetIndex(pos)]
      & (((BitArrayStorageType)1) << GetOffset(pos))) != 0;
  }

  /// Checks whether at least one of \a count bits is set starting at \a pos.
  bool AreSomeBitsSet (size_t pos, size_t count) const
  {
    SAT_ASSERT (pos + count <= mNumBits);
    BitArrayStorageType const* p = GetStore();
    while (count > 0)
    {
      size_t index = GetIndex (pos);
      size_t offset = GetOffset (pos);
      size_t checkCount = MIN(count, cellSize - offset);
      BitArrayStorageType mask = ((checkCount == cellSize)
        ? ~(BitArrayStorageType)0
        : ((((BitArrayStorageType)1) << checkCount) - 1)) << offset;
      if (p[index] & mask)
	return true;
      pos += checkCount;
      count -= checkCount;
    }
    return false;
  }

  /// Returns true if all bits are false.
  bool AllBitsFalse() const
  {
    BitArrayStorageType const* p = GetStore();
    for (size_t i = 0; i < mLength; i++)
      if (p[i] != 0)
        return false;
    return true;
  }

  /// Change value of all bits
  BitArrayTweakable& FlipAllBits()
  {
    BitArrayStorageType* p = GetStore();
    for (size_t i = 0; i < mLength; i++)
      p[i] = ~p[i];
    Trim();
    return *this;
  }

  /**
   * Delete from the array \a count bits starting at \a pos, making the array
   * shorter.
   */
  void Delete(size_t pos, size_t count)
  {
    if (count > 0)
    {
      size_t dst = pos;
      size_t src = pos + count;
      SAT_ASSERT(src <= mNumBits);
      size_t ntail = mNumBits - src;
      while (ntail-- > 0)
	Set(dst++, IsBitSet(src++));
      SetSize(mNumBits - count);
    }
  }

  /**
   * Return a new bit array containing a slice \a count bits in length from
   * this array starting at \a pos. Does not modify this array.
   */
  BitArrayTweakable Slice(size_t pos, size_t count) const
  {
    SAT_ASSERT(pos + count <= mNumBits);
    BitArrayTweakable a (count);
    for (size_t i = pos, o = 0; i < pos + count; i++)
      if (IsBitSet(i))
	a.SetBit(o++);
    return a;
  }

  /// Return the full backing-store.
  BitArrayStorageType* GetArrayBits()
  {
    return GetStore();
  }
};

/**
 * A one-dimensional array of bits, similar to STL bitset.
 * The amount of bits is dynamic at runtime.
 */
class BitArray : public BitArrayTweakable<>
{
public:
  /// Default constructor.
  BitArray () { }
  /// Construct with a size of \a size bits.
  explicit BitArray (size_t size) : BitArrayTweakable<> (size) { }
  /// Construct as duplicate of \a that (copy constructor).
  BitArray (const BitArray& that) : BitArrayTweakable<> (that) { }
};


/**
 * Comparator<> specialization for BitArray to allow its use as
 * e.g. hash key type.
 */
template<>
class Comparator<BitArray, BitArray> :
  public ComparatorBitArray<BitArray> { };


/**
 * HashComputer<> specialization for BitArray to allow its use as
 * hash key type.
 */
template<>
class HashComputer<BitArray> :
  public HashComputerBitArray<BitArray> { };

#endif // __SAT_BITARRAY_H__
