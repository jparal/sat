/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filexdmf.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "filexdmf.h"
#include "base/common/debug.h"
#include "base/sys/assert.h"

IOFile::IOFile ()
  : RefCount ()
{
  Initialize ();
}

void
IOFile::Initialize ()
{
  _parallel = false;
  _shuffle = false;
  _gz = 0;
}

void
IOFile::Initialize (bool parallel, int gz, bool shuffle)
{
  if (gz < 0 || gz >9)
    DBG_WARN ("gz parameter '"<<gz<<"' should be between 0 and 9 (including)");

  if (gz < 0) gz = 0;
  if (gz > 9) gz = 9;

  _parallel = parallel;
  _shuffle = shuffle;
  _gz = gz;
}

void
IOFile::Initialize (const ConfigFile &cfg)
{
  SAT_ASSERT (cfg.Exists ("output.format"));
  ConfigEntry &format = cfg.GetEntry ("output.format");
  Initialize (format);
}

void
IOFile::Initialize (const ConfigEntry &cfg)
{
  bool parallel;
  int gz;
  bool shuffle;
  int version;

  cfg.GetValue ("parallel", parallel, false);
  cfg.GetValue ("version", version, 1);

  if (cfg.Exists ("compress"))
  {
    ConfigEntry &entry = cfg["compress"];
    entry.GetValue ("gz", gz, 6);
    entry.GetValue ("shuffle", shuffle, true);
  }
  else
  {
    DBG_WARN ("Section 'compress' not found.. setting gz = 6 and shuffle = true");
    gz = 6;
    shuffle = true;
  }

  Initialize (parallel, gz, shuffle);
}

// XdmfFile::XdmfFile ()
//   : IOFile ()
// {}

// template<> void XdmfFile::Write<float,3> (Field<float,3> &fld);
