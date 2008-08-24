/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   tester.h
 * @brief  Main header file for tester support
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TESTER_H__
#define __SAT_TESTER_H__

/** @addtogroup test_tester
 *  @{
 */

#include "testbase.h"
#include "testlist.h"
#include "suite.h"
#include "results.h"
#include "runner.h"

#include <new>
#include "macros.h"

#ifndef TESTER_NOMAIN

int *g_pargc;
char ***g_pargv;

int main(int argc, char **argv)
{
  g_pargc = &argc;
  g_pargv = &argv;

  return SAT::Test::RunAllTests (argc, argv);
}

#endif /* TESTER_NOMAIN */

/** @} */

#endif /* __SAT_TESTER_H__ */
