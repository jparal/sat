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

IOManager::~IOManager ()
{
  delete _file;
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
  if (type == "hdf5")
  {
    format = IO_FORMAT_HDF5;
    _file = new HDF5File;
  }
  // else if (type == "stw")
  // {
  //   format = IO_FORMAT_STW;
  //   _file = new STWFile;
  // }
  else
  {
    DBG_WARN ("output.format.type='"<<type<<"' not supported"
	      ", switching to 'hdf5'");
    format = IO_FORMAT_HDF5;
    _file = new HDF5File;
  }

  Initialize (format, runname, dir);

  /**********************/
  /* Initialize drivers */
  /**********************/
  _file->Initialize (cfg);
}

void IOManager::Initialize (const ConfigFile &cfg)
{
  SAT_ASSERT (cfg.Exists ("output.format"));

  ConfigEntry &entry = cfg.GetEntry ("output.format");
  Initialize (entry);
}

String IOManager::GetFileName (const char *tag, const SimulTime &stime)
{
  String name;

  name = GetFileName (tag);
  name += "i";
  name += stime.Iter ();

  return name;
}

String IOManager::GetFileName (const char *tag)
{
  String name;

  if (_dir.IsEmpty ())
  {
    name = tag;
    name += _runname.GetData ();
  }
  else
  {
    IO::Mkdir (_dir);
    name = _dir.GetData ();
    name += "/";
    name += tag;
    name += _runname.GetData ();
  }

  return name;
}
