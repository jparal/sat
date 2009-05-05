/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sws_emit.cxx
 * @brief  Solar Wind Sputtering (SWS) emitter.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "sws_emit.h"
#include "utils.h"

template<class T>
void SWSSphereEmitter<T>::InitializeLocal (ConfigEntry &cfg, Field<T,2> &src)
{
  cfg.GetValue ("ebind", _ebind);
  cfg.GetValue ("etrans", _etrans);
  cfg.GetValue ("mass", _2mass); _2mass = 2./_2mass;
  cfg.GetValue ("mapfname", _mapfname);

  DBG_INFO ("  binding energy Eb [eV]:     "<<_ebind);
  DBG_INFO ("  transmitted energy Tm [eV]: "<<_etrans);
  DBG_INFO ("  mass of the particle:       "<<2./_2mass);
  DBG_INFO ("  input map file:             "<<_mapfname);

  _sigdf.Initialize (_ebind, _etrans);

  // Since Load() function will take care of it based on the dimnesions stored
  // in the file
  src.Free ();
  HIUtils::Load (src, _mapfname);
}

template class SWSSphereEmitter<float>;
template class SWSSphereEmitter<double>;
