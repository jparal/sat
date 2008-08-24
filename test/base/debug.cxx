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

SUITE (DebugSuite)
{
  TEST (BasicTest)
  {
    // std::fstream os ("pokus.out", ios::out);
    // plog_buff.SetStream (&os);
    plog_buff.SetPrefix ("12> ");
    DBG_TUNE (mine);
    DBG_FUNC (DebugSuite, BasicTest);
    DBG_INFO ("Bla");
    DBG_INFO1 ("Ahoj jak se mas? " << 12);
  }
}
