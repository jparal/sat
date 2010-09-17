/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fpe.cxx
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
#if defined(SAT_ENABLE_FPEXCEPTION)

  struct sigaction newaction,oldaction;
  newaction.sa_handler = error_action;
  sigemptyset(&newaction.sa_mask);
  newaction.sa_flags = 0;;
  sigaction(SIGFPE,&newaction,NULL);
  // FE_INEXACT | FE_DIVBYZERO | FE_UNDERFLOW | FE_OVERFLOW | FE_INVALID
  feenableexcept (FE_OVERFLOW | FE_INVALID);

#endif
}

void SAT::DisableFPException ()
{
#if defined(SAT_ENABLE_FPEXCEPTION)

  fedisableexcept (FE_ALL_EXCEPT);

#endif
}
