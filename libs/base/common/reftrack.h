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

#ifndef __SAT_REFTRACK_H__
#define __SAT_REFTRACK_H__

#include "refcount.h"
#include "array.h"
#include "callstack.h"
#include "hash.h"
#include "blkallocator.h"

class RefTracker // : public RefCount
{
  enum RefActionType
  {
    Increased, Decreased, Destructed
  };
  struct RefAction
  {
    RefActionType type;
    int refCount;
    void* tag;
    CallStack* stack;

    RefAction ()
    {
      stack = 0;
    }
    ~RefAction ()
    {
      if (stack) stack->Free();
    }
  };
  struct RefInfo
  {
    Array<RefAction> actions;
    int refCount;
    uint flags;
    const char* descr;

    enum
    {
      /// Object was destructed (ie TrackDestruction() called)
      flagDestructed = 1
    };

    RefInfo() : refCount (0), flags (0), descr(0) { }
  };
  BlockAllocator<RefInfo> riAlloc;
  Hash<void*, void*> aliases;
  Hash<RefInfo*, void*> trackedRefs;
  struct OldRefInfo
  {
    void* obj;
    RefInfo* ri;
  };
  Array<OldRefInfo> oldData;

  //  SAT::Threading::RecursiveMutex mutex;

  RefInfo& GetObjRefInfo (void* obj);

  void ReportOnObj (void* obj, RefInfo* info);

public:
  RefTracker ();
  virtual ~RefTracker ();

  virtual void TrackIncRef (void* object, int refCount);
  virtual void TrackDecRef (void* object, int refCount);
  virtual void TrackConstruction (void* object);
  virtual void TrackDestruction (void* object, int refCount);

  virtual void MatchIncRef (void* object, int refCount, void* tag);
  virtual void MatchDecRef (void* object, int refCount, void* tag);

  virtual void AddAlias (void* obj, void* mapTo);
  virtual void RemoveAlias (void* obj, void* mapTo);

  virtual void SetDescription (void* obj, const char* description);
  virtual void SetDescriptionWeak (void* obj, const char* description);

  void Report ();

protected:
  int ref_count;
  void Delete ()
  { delete this; }

// public:
//   void IncRef ()
//   { ref_count++;  }
//   /// Decrease the number of references to this object.
//   void DecRef ()
//   {
//     ref_count--;
//     if (ref_count <= 0)
//       Delete ();
//   }
//   int GetRefCount () const { return ref_count; }

};

#endif // __SAT_REFTRACK_H__
