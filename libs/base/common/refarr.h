/*
  Crystal Space Smart Pointers
  Copyright (C) 2002 by Jorrit Tyberghein and Matthias Braun

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
 * @file   refarr.h
 * @brief  Special version of Array for smart pointers
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REFARR_H__
#define __SAT_REFARR_H__

//-----------------------------------------------------------------------------
// Note *1*: The explicit "this->" is needed by modern compilers (such as gcc
// 3.4.x) which distinguish between dependent and non-dependent names in
// templates.  See: http://gcc.gnu.org/onlinedocs/gcc/Name-lookup.html
//-----------------------------------------------------------------------------

#include "array.h"
#include "ref.h"

#ifdef SAT_REF_TRACKER
 #include <typeinfo>
 #include "refaccess.h"

 #define SATREFARR_TRACK(x, cmd, refCount, obj, tag) \
  {						    \
    const int rc = obj ? refCount : -1;		    \
    if (obj) cmd;				    \
    if (obj)					    \
    {						    \
      RefTrackerAccess::SetDescription (obj,	    \
	typeid(T).name());			    \
      RefTrackerAccess::Match ## x (obj, rc, tag);\
    }						    \
  }
 #define SATREFARR_TRACK_INCREF(obj,tag)	\
  SATREFARR_TRACK(IncRef, obj->IncRef(), obj->GetRefCount(), obj, tag);
 #define SATREFARR_TRACK_DECREF(obj,tag)	\
  SATREFARR_TRACK(DecRef, obj->DecRef(), obj->GetRefCount(), obj, tag);
#else
 #define SATREFARR_TRACK_INCREF(obj,tag) \
  if (obj) obj->IncRef();
 #define SATREFARR_TRACK_DECREF(obj,tag) \
  if (obj) obj->DecRef();
#endif

template <class T>
class RefArrayElementHandler : public ArrayElementHandler<T>
{
public:
  static void Construct (T* address, T const& src)
  {
    *address = src;
    SATREFARR_TRACK_INCREF (src, address);
  }

  static void Destroy (T* address)
  {
    SATREFARR_TRACK_DECREF ((*address), address);
  }

  static void InitRegion (T* address, size_t count)
  {
    memset (address, 0, count*sizeof (T));
  }
};

/**
 * An array of smart pointers.
 * \warning Get(), GetExtend() and operator[] are unsafe for element
 *   manipulations, as they will return references to pointers and not
 *   proper Ref<> objects - assigning a pointer will circumvent reference
 *   counting and cause unexpected problems. Use Put() to manipulate elements
 *   of the array.
 */
template <class T,
          class Allocator = SAT::Container::ArrayAllocDefault,
          class CapacityHandler = SAT::Container::ArrayCapacityDefault>
class RefArray :
  public Array<T*, RefArrayElementHandler<T*>, Allocator, CapacityHandler>
{
public:
  /**
   * Initialize object to hold initially 'ilimit' elements, and increase
   * storage by 'ithreshold' each time the upper bound is exceeded.
   */
  RefArray (int ilimit = 0,
    const CapacityHandler& ch = CapacityHandler())
    : Array<T*, RefArrayElementHandler<T*>, Allocator, CapacityHandler> (
        ilimit, ch)
  {
  }

  size_t PushNew (T *what)
  {
    size_t size = Push (what);
    what->DecRef ();
    return size;
  }

  /// Pop an element from tail end of array.
  Ptr<T> Pop ()
  {
    SAT_ASSERT (this->GetSize () > 0);
    Ref<T> ret = this->Get (this->GetSize () - 1); // see *1*
    SetSize (this->GetSize () - 1);
    return Ptr<T> (ret);
  }
};

#undef SATREFARR_TRACK_INCREF
#undef SATREFARR_TRACK_DECREF

#endif // __SAT_REFARR_H__
