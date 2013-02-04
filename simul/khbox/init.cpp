/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/02, @jparal}
 * @revmessg{Initial version}
 */

template<class T, int D>
void KHBoxCAMCode<T,D>::PreInitialize (const ConfigFile &cfg)
{
  if (cfg.Exists ("khbox"))
  {
    cfg.GetValue ("khbox.dnjump", _dnjump);
    cfg.GetValue ("khbox.ldjump", _ldjump);
  }
}

template<class T, int D>
void KHBoxCAMCode<T,D>::PostInitialize (const ConfigFile &cfg)
{
  DBG_INFO ("K-H Box initialization:");
  DBG_INFO ("  dn jump        : "<<_dnjump);
  DBG_INFO ("  Ld jump        : "<<_ldjump);
}
