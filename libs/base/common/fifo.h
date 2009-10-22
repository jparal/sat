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
/**
 * @file   fifo.h
 * @brief  First-In-First-Out stack implemenattion on the top of Array
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FIFO_H__
#define __SAT_FIFO_H__

#include "base/common/array.h"

/// @addtogroup base_common
/// @{

/**
 * A FIFO implemented on top of Array<>, but faster than using just
 * a single array.
 */
template <class T, class ElementHandler = ArrayElementHandler<T>,
  class MemoryAllocator = SAT::Memory::AllocatorMalloc>
class FIFO
{
public:
  typedef FIFO<T, ElementHandler, MemoryAllocator> ThisType;
  typedef T ValueType;
  typedef ElementHandler ElementHandlerType;
  typedef MemoryAllocator AllocatorType;

private:
  Array<T, ElementHandler, MemoryAllocator> a1, a2;
public:
  /**
   * Construct the FIFO. See Array<> documentation for meaning of
   * parameters.
   */
  FIFO (size_t icapacity = 0, size_t ithreshold = 0)
    :  a1 (icapacity, ithreshold), a2 (icapacity, ithreshold) { }

  /**
   * Return and remove the first element.
   */
  T PopTop ()
  {
    SAT_ASSERT ((a1.GetSize () > 0) || (a2.GetSize () > 0));
    if (a2.GetSize () == 0)
    {
      size_t n = a1.GetSize ();
      while (n-- > 0)
      {
	a2.Push (a1[n]);
      }
      a1.Empty();
    }
    return a2.Pop();
  }

  /**
   * Push an element onto the FIFO.
   */
  void Push (T const& what)
  {
    a1.Push (what);
  }

  /// Return the number of elements in the FIFO.
  size_t GetSize()
  {
    return a1.GetSize() + a2.GetSize();
  }

  /**
   * Linearly search for an item and delete it.
   * @returns Whether the item was found and subsequently deleled.
   */
  bool Delete (T const& what)
  {
    return (a1.Delete (what) || a2.Delete (what));
  }

  /// Delete all items.
  void DeleteAll ()
  {
    a1.DeleteAll();
    a2.DeleteAll();
  }
};

/// @}

#endif // __SAT_SATUTIL_FIFO_H__
