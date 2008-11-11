/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   iomanager.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "iomanager.h"

IOManager::IOManager ()
{
  Initialize (IO_FORMAT_HDF5, "out", "");
}

void IOManager::Initialize (IOFormat format, String runname, String dir)
{
  _format = format;
  _dir = dir;
  _runname = runname;
}

void IOManager::Initialize (const ConfigEntry &cfg)
{
  String type, dir, runname;
  cfg.GetValue ("type", type, "hdf5");
  cfg.GetValue ("dir", dir, "");
  cfg.GetValue ("runname", runname, "out");

  IOFormat format;
  if (type == "xdmf")
    format = IO_FORMAT_XDMF;
  else if (type == "hdf5")
    format = IO_FORMAT_HDF5;
  else if (type == "stw")
    format = IO_FORMAT_STW;
  else
  {
    DBG_WARN ("output format not supported: "<<type);
    format = IO_FORMAT_HDF5;
  }

  Initialize (format, runname, dir);

  /**********************/
  /* Initialize drivers */
  /**********************/
  _hdf5.Initialize (cfg);
}

void IOManager::Initialize (const ConfigFile &cfg)
{
  SAT_ASSERT (cfg.Exists ("output.format"));

  ConfigEntry &entry = cfg.GetEntry ("output.format");
  Initialize (entry);
}
