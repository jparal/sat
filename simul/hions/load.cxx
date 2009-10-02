/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   load.cxx
 * @brief  Load data from hybrid simulation.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

template<class T>
void HeavyIonsCode<T>::LoadFields ()
{
  DBG_LINE ("Load Data:");

  SAT_PRAGMA_OMP (parallel sections)
  {
    SAT_PRAGMA_OMP (section) HIUtils::Load (_B, 0, "Bx" + _stwname);
    SAT_PRAGMA_OMP (section) HIUtils::Load (_B, 1, "By" + _stwname);
    SAT_PRAGMA_OMP (section) HIUtils::Load (_B, 2, "Bz" + _stwname);

    SAT_PRAGMA_OMP (section) HIUtils::Load (_E, 0, "Ex" + _stwname);
    SAT_PRAGMA_OMP (section) HIUtils::Load (_E, 1, "Ey" + _stwname);
    SAT_PRAGMA_OMP (section) HIUtils::Load (_E, 2, "Ez" + _stwname);
  }
}

#include "tmplspec.cpp"
