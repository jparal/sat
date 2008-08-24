/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   plog.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-28, @jparal}
 * @revmessg{Initial version}
 */

#include "plog.h"
#include "pbuff.h"

ostream plog (&plog_buff);
