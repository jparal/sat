/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cam.cxx
 * @brief  CAM-CL code tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/10, @jparal}
 * @revmessg{Initial version}
 */

#include "efld.h"
#include <signal.h>
#include <fpu_control.h>

// unsigned short flags = _FPU_DEFAULT;
// flags &= ~_FPU_MASK_IM;  /* Exception on Invalid operation */
// flags &= ~_FPU_MASK_ZM;  /* Exception on Division by zero  */
// flags &= ~_FPU_MASK_OM;  /* Exception on Overflow */

// _FPU_SETCW (flags);
// signal(SIGFPE, error_action);

// static void error_action(int error)
// {
//    fprintf(stderr, "floating point exception -- program abort!\n");
//    abort();
// }

SUITE (CAMSuite)
{
  TEST (EfldTest)
  {
    EfldTestCAMCode<float> test;
    test.Initialize (g_pargc, g_pargv);
    test.Check ();
  }
}
