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
#include "refaccess.h"
#include "reftrack.h"
#include "ref.h"

#ifdef SAT_REF_TRACKER

RefTracker sRefTracker;

static inline RefTracker* GetRefTracker()
{
  return &sRefTracker;
}

// #define TRACKER_CALL_(method, params)		    	\
//   {						    	\
//     RefTracker* refTracker;				\
//     if ((refTracker = GetRefTracker()))			\
//     {						    	\
//       refTracker-> method params;  			\
//       refTracker->DecRef ();			    	\
//     }						    	\
//   }

#define TRACKER_CALL_(method, params)		    	\
  {						    	\
    RefTracker* refTracker;				\
    if ((refTracker = GetRefTracker()))			\
    {						    	\
      refTracker-> method params;  			\
    }						    	\
  }

#define TRACKER_CALL1(method, p1)	  TRACKER_CALL_(method, (p1))
#define TRACKER_CALL2(method, p1, p2)	  TRACKER_CALL_(method, (p1, p2))
#define TRACKER_CALL3(method, p1, p2, p3) TRACKER_CALL_(method, (p1, p2, p3))

void RefTrackerAccess::TrackIncRef (void* object, int refCount)
{
  TRACKER_CALL2 (TrackIncRef, object, refCount);
}

void RefTrackerAccess::TrackDecRef (void* object, int refCount)
{
  TRACKER_CALL2 (TrackDecRef, object, refCount);
}

void RefTrackerAccess::TrackConstruction (void* object)
{
  TRACKER_CALL1 (TrackConstruction, object);
}

void RefTrackerAccess::TrackDestruction (void* object, int refCount)
{
  TRACKER_CALL2 (TrackDestruction, object, refCount);
}

void RefTrackerAccess::MatchIncRef (void* object, int refCount, void* tag)
{
  TRACKER_CALL3 (MatchIncRef, object, refCount, tag);
}

void RefTrackerAccess::MatchDecRef (void* object, int refCount, void* tag)
{
  TRACKER_CALL3 (MatchDecRef, object, refCount, tag);
}

void RefTrackerAccess::AddAlias (void* obj, void* mapTo)
{
  TRACKER_CALL2 (AddAlias, obj, mapTo);
}

void RefTrackerAccess::RemoveAlias (void* obj, void* mapTo)
{
  TRACKER_CALL2 (RemoveAlias, obj, mapTo);
}

void RefTrackerAccess::SetDescription (void* obj, const char* description)
{
  TRACKER_CALL2 (SetDescription, obj, description);
}

#endif // SAT_REF_TRACKER
