/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   assert.cxx
 * @brief  Assert function implementation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "stdhdrs.h"
#include "assert.h"
#include "base/common/callstack.h"

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

      fprintf (stderr,
	"Assertion: %s\n", expr);
      fprintf (stderr,
	"Location:  %s:%d\n", filename, line);
      if (msg) fprintf (stderr,
	"Message:   %s\n", msg);
      fflush (stderr);

#if 0
      CallStack* stack = CallStackHelper::CreateCallStack (1);
      if (stack != 0)
      {
	fprintf (stderr, "Call stack:\n");
	stack->Print (stderr);
	fflush (stderr);
	stack->Free();
      }
#endif

      assertCnt--;

      const char* ignoreEnv = getenv ("SAT_ASSERT_IGNORE");
      if (!ignoreEnv || (atoi (ignoreEnv) == 0))
      {
	SAT_DEBUG_BREAK;
      }
    }

  } // namespace Debug
} // namespace SAT
