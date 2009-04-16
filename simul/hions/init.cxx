/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cxx
 * @brief  Heavy ions initialization.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#include "hions.h"

HeavyIonsCode::HeavyIonsCode ()
{
}

HeavyIonsCode::~HeavyIonsCode ()
{
}

void
HeavyIonsCode::Initialize (int *pargc, char ***pargv)
{
  // Don't initialize MPI but only OpenMP
  Code::Initialize (pargc, pargv, false, true);
  ConfigFile &cfg = Code::GetCfgFile ();
  satversion_t ver = Code::GetCfgVersion ();

  _time.Initialize (cfg, ver);
  cfg.GetValue ("simul.clean", _clean);

  cfg.GetValue ("input.fname", _stwname);
  cfg.GetValue ("input.cells", _nx);
  cfg.GetValue ("input.resol", _dx);
  cfg.GetValue ("input.scalef", _scalef);

  cfg.GetValue ("input.planet.rpos", _rx);
  cfg.GetValue ("input.planet.radius", _radius);

  DBG_INFO ("Heavy ions simulation:");
  DBG_INFO ("  clean particle every:   "<<_clean);
  DBG_INFO ("  input STW file name:    "<<_stwname);
  DBG_INFO ("  number of cells:        "<<_nx);
  DBG_INFO ("  resolution of STW data: "<<_dx);
  DBG_INFO ("  scale factor of ions:   "<<_scalef);
  DBG_INFO ("  planet position:        "<<_rx);
  DBG_INFO ("  planet radius:          "<<_radius);

  DBG_LINE ("Sensors:");
  _sensmng.Initialize (cfg);

  DBG_LINE ("Load Data:");
  SAT_PRAGMA_OMP (parallel sections)
  {
    SAT_PRAGMA_OMP (section) Load (_B, 0, "Bx" + _stwname);
    SAT_PRAGMA_OMP (section) Load (_B, 1, "By" + _stwname);
    SAT_PRAGMA_OMP (section) Load (_B, 2, "Bz" + _stwname);

    SAT_PRAGMA_OMP (section) Load (_E, 0, "Ex" + _stwname);
    SAT_PRAGMA_OMP (section) Load (_E, 1, "Ey" + _stwname);
    SAT_PRAGMA_OMP (section) Load (_E, 2, "Ez" + _stwname);
  }

  HDF5File file;
  file.Initialize (cfg);
  SAT_PRAGMA_OMP (parallel sections)
  {
    SAT_PRAGMA_OMP (section) file.Write (_B, Cell, "B", "Bpokus");
    SAT_PRAGMA_OMP (section) file.Write (_E, Cell, "E", "Epokus");
  }
}
