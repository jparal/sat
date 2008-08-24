/*
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
/**
 * @file   refaccess.h
 * @brief  Reference tracker access.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_REFACCESS_H__
#define __SAT_REFACCESS_H__

#include "satconfig.h"

#if defined(SAT_DEBUG)
#  if defined(SAT_DEBUG_REF_TRACKER)
#    define SAT_REF_TRACKER
#  endif
#else
#  undef SAT_REF_TRACKER
#endif

// #ifndef SAT_REF_TRACKER
//   // @@@ HACK: to allow enabled and disabled versions to coexist
//   #define RefTrackerAccess	RefTrackerAccess_nada
// #endif

/**
 * Helper to facilitate access to the global reference tracker. The reference
 * tracker interface.
 */
class RefTrackerAccess
{
public:
#ifndef SAT_REF_TRACKER
  /// Called by an object if it has been IncRef()ed.
  static void TrackIncRef (void*, int) {}
  /// Called by an object if it has been DecRef()ed.
  static void TrackDecRef (void*, int) {}
  /// Called by an object if it constructed.
  static void TrackConstruction (void*) {}
  /// Called by an object if it destructed.
  static void TrackDestruction (void*, int) {}

  /**
   * Match the most recent IncRef() to a 'tag' so it can be tracked what
   * IncRef()ed a ref. Ref<>s employ this mechanism and tag IncRef()s
   * with 'this'.
   */
  static void MatchIncRef (void*, int, void*) {}
  /**
   * Match the most recent DecRef() to a 'tag' so it can be tracked what
   * DecRef()ed a ref. Ref<>s employ this mechanism and tag DecRef()s
   * with 'this'.
   */
  static void MatchDecRef (void*, int, void*) {}

  /**
   * Add an alias. Basically says "mapTO is the same as obj." Used for
   * embedded interfaces.
   */
  static void AddAlias (void*, void*) {}
  /**
   * Remove an alias.
   */
  static void RemoveAlias (void*, void*) {}

  /**
   * Set description for an object.
   * \remarks Currently the provided description pointer is
   *  <b>stored as-is</b>. That means the string must be constant!
   */
  static void SetDescription (void*, const char*) {}
  /**
   * Set description for an object, but only if no description has been set
   * yet.
   * \remarks Currently the provided description pointer is
   *  <b>stored as-is</b>. That means the string must be constant!
   */
  static void SetDescriptionWeak (void* obj, const char* description) {}
#else
  static void TrackIncRef (void* object, int refCount);
  static void TrackDecRef (void* object, int refCount);
  static void TrackConstruction (void* object);
  static void TrackDestruction (void* object, int refCount);

  static void MatchIncRef (void* object, int refCount, void* tag);
  static void MatchDecRef (void* object, int refCount, void* tag);

  static void AddAlias (void* obj, void* mapTo);
  static void RemoveAlias (void* obj, void* mapTo);

  static void SetDescription (void* obj, const char* description);
  static void SetDescriptionWeak (void* obj, const char* description);
#endif
};

#endif /* __SAT_REFACCESS_H__ */
