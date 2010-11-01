/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   clock.h
 * @brief  System wrapper around processor clocks (i.e. function @c times )
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/10, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CLOCK_H__
#define __SAT_CLOCK_H__

/// @addtogroup base_sys
/// @{

#include "satconfig.h"
#include "stdhdrs.h"

/**
 */
struct Clock
{
  static void GetWallTime (double& wall);

  /// Returns clock cycle for the system.
  static double ClockCycle ();
};

/// @}

#endif /* __SAT_CLOCK_H__ */
