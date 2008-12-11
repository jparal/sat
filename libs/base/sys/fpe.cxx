/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   onsignal.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#include "fpe.h"

#include <stdio.h>
#include <stdlib.h>

static void error_action(int error)
{
   fprintf(stderr, "floating point exception -- program abort!\n");
   abort();
}

void SAT::EnableFPException ()
{
  unsigned short flags = _FPU_DEFAULT;
  flags &= ~_FPU_MASK_IM;  /* Exception on Invalid operation */
  flags &= ~_FPU_MASK_ZM;  /* Exception on Division by zero  */
  flags &= ~_FPU_MASK_OM;  /* Exception on Overflow */

  _FPU_SETCW (flags);
  signal(SIGFPE, error_action);
}
