/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   alfven.cxx
 * @brief  Alfven wave CAM-CL simulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "alfven.h"
#include <signal.h>
#include <fpu_control.h>

static void error_action(int error)
{
   fprintf(stderr, "floating point exception -- program abort!\n");
   abort();
}

int main (int argc, char **argv)
{
  unsigned short flags = _FPU_DEFAULT;
  flags &= ~_FPU_MASK_IM;  /* Exception on Invalid operation */
  flags &= ~_FPU_MASK_ZM;  /* Exception on Division by zero  */
  flags &= ~_FPU_MASK_OM;  /* Exception on Overflow */

  _FPU_SETCW (flags);
  signal(SIGFPE, error_action);

  AlfvenCAMCode<float,1> alfven;
  alfven.Initialize (&argc, &argv);
  alfven.Exec ();

  return 0;
}
