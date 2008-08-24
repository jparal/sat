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
  Initialize (IO_FORMAT_XDMF, "out");
}

void IOManager::Initialize (IOFormat format, String runname)
{
  _format = format;
  _runname = runname;
}

void IOManager::Initialize (const ConfigEntry &cfg)
{
  String type, runname;
  cfg.GetValue ("type", type, "xdmf");
  cfg.GetValue ("runname", runname, "out");

  IOFormat format;
  if (type == "xdmf")
    format = IO_FORMAT_XDMF;
  else
  {
    DBG_WARN ("output format not supported: "<<type);
    format = IO_FORMAT_XDMF;
  }

  Initialize (format, runname);

  /**********************/
  /* Initialize drivers */
  /**********************/
  _xdmf.Initialize (cfg);
}

void IOManager::Initialize (const ConfigFile &cfg)
{
  SAT_ASSERT (cfg.Exists ("output.format"));

  ConfigEntry &entry = cfg.GetEntry ("output.format");
  Initialize (entry);
}
