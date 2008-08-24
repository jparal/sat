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
 * @file   ref.h
 * @brief  Smart pointer implementation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REF_H__
#define __SAT_REF_H__

#include "base/sys/assert.h"
#include "base/sys/porttypes.h"

#define SAT_VOIDED_PTR ((intptr_t)-1)

template <class T> class Ref;

#if defined(SAT_DEBUG)
#  define SAT_TEST_VOIDPTRUSAGE
#  if defined(SAT_DEBUG_REF_TRACKER)
#    define SAT_REF_TRACKER
#  endif
#else
#  undef SAT_TEST_VOIDPTRUSAGE
#  undef SAT_REF_TRACKER
#endif

#ifdef SAT_REF_TRACKER
#  include <typeinfo>
#  include "refaccess.h"

#  define SATREF_TRACK(x, cmd, refCount, obj, tag)		\
  {								\
    const int rc = obj ? refCount : -1;				\
    if (obj)							\
    {								\
      cmd;							\
      RefTrackerAccess::SetDescription (obj,			\
					typeid(T).name());	\
      RefTrackerAccess::Match ## x (obj, rc, tag);		\
    }								\
  }
#  define SATREF_TRACK_INCREF(obj,tag)					\
  SATREF_TRACK(IncRef, obj->IncRef(), obj->GetRefCount(), obj, tag);
#  define SATREF_TRACK_DECREF(obj,tag)					\
  SATREF_TRACK(DecRef, obj->DecRef(), obj->GetRefCount(), obj, tag);
#  define SATREF_TRACK_ASSIGN(obj,tag)					\
  SATREF_TRACK(IncRef, void(0), obj->GetRefCount() - 1, obj, tag);
#else
#  define SATREF_TRACK_INCREF(obj,tag)		\
  if (obj) obj->IncRef();
#  define SATREF_TRACK_DECREF(obj,tag)		\
  if (obj) obj->DecRef();
#  define SATREF_TRACK_ASSIGN(obj,tag)
#endif

/**
 * A pointer encapsulator.
 * Represents a single, owned, one-time-transferable reference to an object
 * and should be used only as the return value of a function, or when
 * creating a brand new object which is assigned directly to a Ref<>.
 * Ptr<> simply stores the pointer (it never invokes IncRef() or DecRef()).
 * It is very specialized, and exists solely as a mechanism for transferring
 * an existing reference into a Ref<>.
 *
 * \b Important: There is only one valid way to use the result of a function
 * which returns a Ptr<>: assign it to a Ref<>.
 *
 * \remarks An extended explanation on smart pointers - how they work and what
 *   type to use in what scenario - is contained in the User's manual,
 *   section "Correctly Using Smart Pointers".
 */
template <class T>
class  Ptr
{
private:
  friend class Ref<T>;
  T* obj;

public:
  Ptr (T* p) : obj (p) { SATREF_TRACK_ASSIGN(obj, this); }

  template <class T2>
  explicit Ptr (Ref<T2> const& r) : obj((T2*)r)
  {
    SATREF_TRACK_INCREF (obj, this);
  }

#ifdef SAT_TEST_VOIDPTRUSAGE
  ~Ptr ()
  {
    // If not assigned to a Ref we have a problem (leak).
    // So if this assert fires for you, then you are calling
    // a function that returns a Ptr and not using the result
    // (or at least not assigning it to a Ref). This is a memory
    // leak and you should fix that.
    SAT_ASSERT_MSG (obj == (T*)SAT_VOIDED_PTR,
		    "Ptr<> was not assigned to a Ref<> prior destruction");
  }
#endif

  Ptr (const Ptr<T>& copy)
  {
    obj = copy.obj;
#ifdef SAT_TEST_VOIDPTRUSAGE
    ((Ptr<T>&)copy).obj = (T*)SAT_VOIDED_PTR;
#endif
  }
};

/**
 * A smart pointer.  Maintains and correctly manages a reference to a
 * reference-counted object.  This template requires only that the object type
 * T implement the methods IncRef() and DecRef().  No other requirements are
 * placed upon T.
 *
 * \remarks An extended explanation on smart pointers - how they work and what
 *   type to use in what scenario - is contained in the User's manual,
 *   section "Correctly Using Smart Pointers".
 */
template <class T>
class Ref
{
private:
  T* obj;

public:
  /**
   * Construct an invalid smart pointer (that is, one pointing at nothing).
   * Dereferencing or attempting to use the invalid pointer will result in a
   * run-time error, however it is safe to invoke IsValid().
   */
  Ref () : obj (0) {}

  /**
   * Construct a smart pointer from a Ptr. Doesn't call IncRef() on
   * the object since it is assumed that the object in Ptr is already
   * IncRef()'ed.
   */
  Ref (const Ptr<T>& newobj)
  {
    obj = newobj.obj;
#ifdef SAT_TEST_VOIDPTRUSAGE
    SAT_ASSERT_MSG (newobj.obj != (T*)SAT_VOIDED_PTR,
		    "Ptr<> was already assigned to a Ref<>");
#endif
    // The following line is outside the ifdef to make sure
    // we have binary compatibility.
    ((Ptr<T>&)newobj).obj = (T*)SAT_VOIDED_PTR;
  }

  /**
   * Construct a smart pointer from a raw object reference. Calls IncRef()
   * on the object.
   */
  Ref (T* newobj) : obj (newobj)
  {
    SATREF_TRACK_INCREF (obj, this);
  }

  /**
  * Construct a smart pointer from a raw object reference with a compatible
  * type. Calls IncRef() on the object.
  */
  template <class T2>
  Ref (T2* newobj) : obj ((T2*)newobj)
  {
    SATREF_TRACK_INCREF (obj, this);
  }

  /**
   * Smart pointer copy constructor from assignment-compatible Ref<T2>.
   */
  template <class T2>
  Ref (Ref<T2> const& other) : obj ((T2*)other)
  {
    SATREF_TRACK_INCREF (obj, this);
  }

  /**
   * Smart pointer copy constructor.
   */
  Ref (Ref const& other) : obj (other.obj)
  {
    SATREF_TRACK_INCREF (obj, this);
  }

  /**
   * Smart pointer destructor.  Invokes DecRef() upon the underlying object.
   */
  ~Ref ()
  {
    SATREF_TRACK_DECREF (obj, this);
  }

  /**
   * Create new object by calling operator new. Proper usage should look like
   * this:
   * \code
   * Ref<SimulTime> st = Ref<SimulTime>::New ();
   * \endcode
   * @return new object
   */
  static Ptr<T> New ()
  { return Ptr<T> (new T); };

  /**
   * Assign a Ptr to a smart pointer. Doesn't call IncRef() on
   * the object since it is assumed that the object in Ptr is already
   * IncRef()'ed.
   * \remarks
   * After this assignment, the Ptr<T> object is invalidated and cannot
   * be used. You should not (and in fact cannot) decref the Ptr<T> after
   * this assignment has been made.
   */
  Ref& operator = (const Ptr<T>& newobj)
  {
    T* oldobj = obj;
    // First assign and then DecRef() of old object!
    obj = newobj.obj;
#ifdef SAT_TEST_VOIDPTRUSAGE
    SAT_ASSERT_MSG (newobj.obj != (T*)SAT_VOIDED_PTR,
		    "Ptr<> was already assigned to a Ref<>");
#endif
    // The following line is outside the ifdef to make sure
    // we have binary compatibility.
    ((Ptr<T>&)newobj).obj = (T*)SAT_VOIDED_PTR;
    SATREF_TRACK_DECREF (oldobj, this);
    return *this;
  }

  /**
   * Assign a raw object reference to this smart pointer.
   * \remarks
   * This function calls the object's IncRef() method. Because of this you
   * should not assign a reference created with the new operator to a Ref
   * object driectly. The following code will produce a memory leak:
   * \code
   * Ref<iEvent> event = new Event;
   * \endcode
   * If you are assigning a new object to a Ref, use AttachNew(T* newObj)
   * instead.
   */
  Ref& operator = (T* newobj)
  {
    if (obj != newobj)
    {
      T* oldobj = obj;
      // It is very important to first assign the new value to
      // 'obj' BEFORE calling DecRef() on the old object. Otherwise
      // it is easy to get in infinite loops with objects being
      // destructed forever (when ref=0 is used for example).
      obj = newobj;
      SATREF_TRACK_INCREF (newobj, this);
      SATREF_TRACK_DECREF (oldobj, this);
    }
    return *this;
  }

  /**
   * Assign an object reference created with the new operator to this smart
   * pointer.
   * \remarks
   * This function allows you to assign an object pointer created with the
   * \c new operator to the Ref object. Proper usage would be:
   * \code
   * Ref<iEvent> event;
   * event.AttachNew (new Event);
   * \endcode
   * While not recommended, you can also use this function to assign a Ptr
   * object or Ref object to the Ref. In both of these cases, using
   * AttachNew is equivalent to performing a simple assignment using the
   * \c = operator.
   * \note
   * Calling this function is equivalent to casting an object to a Ptr<T>
   * and then assigning the Ptr<T> to the Ref, as follows:
   * \code
   * // Same effect as above code.
   * Ref<iEvent> event = Ptr<iEvent> (new Event);
   * \endcode
   */
  void AttachNew (Ptr<T> newObj)
  {
    // Note: The parameter usage of Ptr<T> instead of Ptr<T>& is
    // deliberate and not to be considered a bug.

    // Just Re-use Ptr assignment logic
    *this = newObj;
  }

  /// Assign another assignment-compatible Ref<T2> to this one.
  template <class T2>
  Ref& operator = (Ref<T2> const& other)
  {
    T* p = (T2*)other;
    this->operator=(p);
    return *this;
  }

  /// Assign another Ref<> of the same type to this one.
  Ref& operator = (Ref const& other)
  {
    this->operator=(other.obj);
    return *this;
  }

  /// Test if the two references point to same object.
  inline friend bool operator == (const Ref& r1, const Ref& r2)
  {
    return r1.obj == r2.obj;
  }
  /// Test if the two references point to different object.
  inline friend bool operator != (const Ref& r1, const Ref& r2)
  {
    return r1.obj != r2.obj;
  }
  /// Test if object pointed to by reference is same as obj.
  inline friend bool operator == (const Ref& r1, T* obj)
  {
    return r1.obj == obj;
  }
  /// Test if object pointed to by reference is different from obj.
  inline friend bool operator != (const Ref& r1, T* obj)
  {
    return r1.obj != obj;
  }
  /// Test if object pointed to by reference is same as obj.
  inline friend bool operator == (T* obj, const Ref& r1)
  {
    return r1.obj == obj;
  }
  /// Test if object pointed to by reference is different from obj.
  inline friend bool operator != (T* obj, const Ref& r1)
  {
    return r1.obj != obj;
  }
  /**
   * Test the relationship of the addresses of two objects.
   * \remarks Mainly useful when Ref<> is used as the subject of
   *   Comparator<>, which employs operator< for comparisons.
   */
  inline friend bool operator < (const Ref& r1, const Ref& r2)
  {
    return r1.obj < r2.obj;
  }


  /// Dereference underlying object.
  T* operator -> () const
  { return obj; }

  /// Cast smart pointer to a pointer to the underlying object.
  operator T* () const
  { return obj; }

  /// Dereference underlying object.
  T& operator* () const
  { return *obj; }

  operator bool ()
  { return (obj != 0); }

  /**
   * Smart pointer validity check.  Returns true if smart pointer is pointing
   * at an actual object, otherwise returns false.
   */
  bool IsValid () const
  { return (obj != 0); }

  /// Invalidate the smart pointer by setting it to null.
  void Invalidate()
  { *this = (T*)0; }

  /// Return a hash value for this smart pointer.
  uint32_t GetHash() const
  { return (uintptr_t)obj;  }
};

#undef SATREF_TRACK_INCREF
#undef SATREF_TRACK_DECREF
#undef SATREF_TRACK_ASSIGN

#endif //SAT_REF_H
