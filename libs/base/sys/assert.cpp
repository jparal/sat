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

#include "satsysdef.h"
#include "common/sysfunc.h"

#include "common/callstack.h"

namespace SAT
{
  namespace Debug
  {
    
    void AssertMessage (const char* expr, const char* filename, int line,
			 const char* msg)
    {
      static int assertCnt = 0;
      
      if (assertCnt == 1)
      {
        // Avoid FPrintf - it may trigger an assert itself again...
	fprintf (stderr, "Whoops, assertion while reporting assertion...\n");
	fprintf (stderr, 
	  "Assertion failed: %s\n", expr);
	fprintf (stderr, 
	  "Location:         %s:%d\n", filename, line);
	if (msg) fprintf (stderr, 
	  "Message:          %s\n", msg);
	fflush (stderr);
	SAT_DEBUG_BREAK;
	return;
      }
      
      assertCnt++;
      
      FPrintf (stderr, 
	"Assertion failed: %s\n", expr);
      FPrintf (stderr, 
	"Location:         %s:%d\n", filename, line);
      if (msg) FPrintf (stderr, 
	"Message:          %s\n", msg);
      fflush (stderr);

      CallStack* stack = CallStackHelper::CreateCallStack (1);
      if (stack != 0)
      {
	FPrintf (stderr, "Call stack:\n");
	stack->Print (stderr);
	fflush (stderr);
	stack->Free();
      }

      assertCnt--;
      
      const char* ignoreEnv = getenv ("SAT_ASSERT_IGNORE");
      if (!ignoreEnv || (atoi (ignoreEnv) == 0))
      {
	SAT_DEBUG_BREAK;
      }
    }
    
  } // namespace Debug
} // namespace SAT
