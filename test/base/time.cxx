/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   debug.cxx
 * @brief  Debug desting
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-25, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "satpint.h"
#include "base/common/pbuff.h"
#include "base/common/debug.h"

#include <fstream>

SUITE (TimeSuite)
{
  TEST (BasicTest)
  {
    Timer time;
    time.Start ();
    sleep (1);
    time.Stop ();
    DBG_INFO ("Time elapsed: " << time);
    DBG_INFO (time.GetWallclockTime ());
  }
}
