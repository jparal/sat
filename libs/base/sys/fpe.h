/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fpe.h
 * @brief  Enable handler of floating point exceptions.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ONSIGNAL_H__
#define __SAT_ONSIGNAL_H__

#include "satconfig.h"

#if defined(HAVE_SIGNAL_H) && defined(HAVE_FPU_CONTROL_H)
#  define SAT_ENABLE_FPEXCEPTION 1
#  include <signal.h>
#  include <fpu_control.h>
#endif

/// @addtogroup base_sys
/// @{

namespace SAT
{
  /// Enable floating point exception
  void EnableFPException ();
};

/// @}

#endif /* __SAT_ONSIGNAL_H__ */
