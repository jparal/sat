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

#include "satsysdef.h"

#undef SAT_REF_TRACKER
#include "callstack.h"

#include "reftrack.h"

RefTracker::RefTracker () //: ref_count (1)
{
}

RefTracker::~RefTracker ()
{
  Report ();
}

RefTracker::RefInfo& RefTracker::GetObjRefInfo (void* obj)
{
  obj = aliases.Get (obj, obj);
  RefInfo* info = trackedRefs.Get (obj, 0);
  if (info == 0)
  {
    info = riAlloc.Alloc();
    trackedRefs.Put (obj, info);
  }
  return *info;
}

void RefTracker::TrackIncRef (void* object, int refCount)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (object);
  RefAction& action = refInfo.actions.GetExtend (refInfo.actions.GetSize ());
  action.type = Increased;
  action.refCount = refCount;
  action.stack = CallStackHelper::CreateCallStack (1, true);
  action.tag = 0;
  refInfo.refCount = refCount + 1;
}

void RefTracker::TrackDecRef (void* object, int refCount)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (object);
  RefAction& action = refInfo.actions.GetExtend (refInfo.actions.GetSize ());
  action.type = Decreased;
  action.refCount = refCount;
  action.stack = CallStackHelper::CreateCallStack (1, true);
  action.tag = 0;
  refInfo.refCount = refCount - 1;
}

void RefTracker::TrackConstruction (void* object)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  /*
    Move the already tracked object to the "old data".
    The new one might just coincidentally be alloced at the same spot.
   */
  RefInfo* oldRef = trackedRefs.Get (object, 0);
  if (oldRef != 0)
  {
    oldRef->actions.ShrinkBestFit();
    OldRefInfo oldInfo = {object, oldRef};
    oldData.Push (oldInfo);
    trackedRefs.DeleteAll (object);
  }
  /*
    @@@ It may happen that this pointer was aliased to some other location,
    but the alias hasn't been removed.
   */
  aliases.DeleteAll (object);
  TrackIncRef (object, 0);
}

void RefTracker::TrackDestruction (void* object, int refCount)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (object);
  RefAction& action = refInfo.actions.GetExtend (refInfo.actions.GetSize ());
  action.type = Destructed;
  action.refCount = refCount;
  action.stack = CallStackHelper::CreateCallStack (1, true);
  action.tag = 0;
  refInfo.refCount = refCount;
  refInfo.flags |= RefInfo::flagDestructed;
}

void RefTracker::MatchIncRef (void* object, int refCount, void* tag)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (object);
  bool foundAction = false;
  size_t i = refInfo.actions.GetSize ();
  while (i > 0)
  {
    i--;
    if (refInfo.actions[i].refCount == refCount)
    {
      if (refInfo.actions[i].tag == 0)
      {
	refInfo.actions[i].tag = tag;
	foundAction = true;
      }
      break;
    }
  }
  if (!foundAction)
  {
    RefAction& action = refInfo.actions.GetExtend (refInfo.actions.GetSize ());
    action.type = Increased;
    action.refCount = refCount;
    action.stack = CallStackHelper::CreateCallStack (1, true);
    action.tag = tag;
    refInfo.refCount = refCount + 1;
  }
}

void RefTracker::MatchDecRef (void* object, int refCount, void* tag)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (object);
  bool foundAction = false;
  size_t i = refInfo.actions.GetSize ();
  while (i > 0)
  {
    i--;
    if (refInfo.actions[i].refCount == refCount)
    {
      if (refInfo.actions[i].tag == 0)
      {
	refInfo.actions[i].tag = tag;
	foundAction = true;
      }
      break;
    }
  }
  if (!foundAction)
  {
    RefAction& action = refInfo.actions.GetExtend (refInfo.actions.GetSize ());
    action.type = Decreased;
    action.refCount = refCount;
    action.stack = CallStackHelper::CreateCallStack (1, true);
    action.tag = tag;
    refInfo.refCount = refCount - 1;
  }
}

void RefTracker::AddAlias (void* obj, void* mapTo)
{
  if (obj == mapTo) return;

  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  aliases.PutUnique (obj, mapTo);
}

void RefTracker::RemoveAlias (void* obj, void* mapTo)
{
  if (obj == mapTo) return;

  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  aliases.Delete (obj, mapTo);
}

void RefTracker::SetDescription (void* obj, const char* description)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (obj);
  refInfo.descr = description;
}

void RefTracker::SetDescriptionWeak (void* obj, const char* description)
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  RefInfo& refInfo = GetObjRefInfo (obj);
  if (refInfo.descr == 0)
    refInfo.descr = description;
}

void RefTracker::ReportOnObj (void* obj, RefInfo* info)
{
  bool okay = (info->refCount == 0)
    /* The next check is to "let through" objects that have been
     * destructed with a refcount of 1 remaining
     * (e.g. ref counted objects created on the stack). */
     || ((info->flags & RefInfo::flagDestructed) && (info->refCount == 1));
  if (!okay)
  {
    printf ("LEAK: object %p (%s), refcount %d, %s\n",
      obj,
      info->descr ? info->descr : "<unknown>",
      info->refCount,
      (info->flags & RefInfo::flagDestructed) ? "destructed" : "not destructed");
    for (size_t i = 0; i < info->actions.GetSize (); i++)
    {
      printf ("%s by %p from %d\n",
	(info->actions[i].type == Increased) ? "Increase" : "Decrease",
	info->actions[i].tag,
	info->actions[i].refCount);
      if (info->actions[i].stack != 0)
	info->actions[i].stack->Print ();
    }
    printf ("\n");
  }
}

void RefTracker::Report ()
{
  //  SAT::Threading::RecursiveMutexScopedLock lock (mutex);

  for (size_t i = 0; i < oldData.GetSize (); i++)
  {
    const OldRefInfo& oldInfo = oldData[i];

    ReportOnObj (oldInfo.obj, oldInfo.ri);
  }

  Hash<RefInfo*, void*>::GlobalIterator it (
    trackedRefs.GetIterator ());

  while (it.HasNext ())
  {
    void* obj;
    RefInfo* info = it.Next (obj);

    ReportOnObj (obj, info);
  }
}
