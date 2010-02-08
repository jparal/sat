/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#include "code.h"
#include "satpint.h"

Code::Code () {}

Code::~Code ()
{
  Finalize ();
}

void Code::Initialize (int *pargc, char ***pargv, bool mpi, bool omp)
{
  bool enthreads = false;
  int threads = -1;

  if (mpi) Mpi::Initialize (pargc, pargv);

  _argc = *pargc;
  _argv = *pargv;

  _exename = _argv[0];
  _logname = _exename;
  _logname += ".log";
  _cfgname = _exename;
  _cfgname += ".sin";
  _cfgname.ReplaceAll ("test-", "");
  _cfgname.ReplaceAll ("sat-", "");

  // Handle all parameters
  for (int i=1; i<_argc; ++i)
  {
    if (!strcmp (_argv[i], "--threads"))
    {
      enthreads = true;
      threads = atoi (_argv[++i]);
    }
    else if (!strcmp (_argv[i], "--help") || !strcmp (_argv[i], "-h"))
    {
#if HAVE_OPENMP
      if (omp)
	printf ("  --threads N   Number of threads which OpenMP should use.\n");
#endif //HAVE_OPENMP
    }
    else
    {
      _cfgname = _argv[i];
    }
  }

  char cproc[6];
  snprintf (cproc, 6, "%.3d> ", Mpi::Rank ());
  DBG_PREFIX (cproc);
  DBG_ENABLE (Mpi::Rank () == 0);

  DBG_INFO (PACKAGE_NAME" v"PACKAGE_VERSION);
  DBG_INFO (PACKAGE_COPYRIGHT);
  DBG_INFO ("Architecture: "PLATFORM_NAME"/"PLATFORM_OS_NAME" v"<<
	    PLATFORM_OS_VERSION<< "/"PLATFORM_PROCESSOR_NAME);
  DBG_INFO ("Compiler:     "_STRINGIFY(PLATFORM_COMPILER_FAMILYNAME)" v"
	    PLATFORM_COMPILER_VERSION_STR" ("SAT_MODE" mode)");
  DBG_INFO ("C++ flags:    "SAT_CXXFLAGS);
  DBG_INFO ("Configured:   "CONFIGURE_DATE);
  DBG_INFO ("Report bugs:  "PACKAGE_BUGREPORT);
  DBG_LINE ("");

  const char *file = _cfgname.GetData ();
  try
  {
    _cfg.ReadFile (file);
    _cfg.SetAutoConvert ();
  }
  catch (ParseException &ex)
  {
    SAT_ABBORT (file<<"(" << ex.GetLine() << "): Parsing error: " <<
		ex.GetError() << endl);
  }
  catch (FileIOException &ex)
  {
    SAT_ABBORT ("Parsing file: '"<<file<<"'");
  }

  int ver[3];
  if (_cfg.Exists ("sat.version"))
  {
    ConfigEntry &ent = _cfg.GetEntry ("sat.version");
    int len = ent.GetLength ();
    if (len>=1) ver[0] = ent[0]; else ver[0] = 0;
    if (len>=2) ver[1] = ent[1]; else ver[1] = 0;
    if (len>=3) ver[2] = ent[2]; else ver[2] = 0;
  }
  else
  {
    ver[0] = 0; ver[1] = 3; ver[2] = 0;
  }
  _ver = SAT_VERSION_MAKE (ver[0], ver[1], ver[2]);

  _cfg.GetValue ("output.logfile", _logname, _logname);

  DBG_INFO1 ("exe file:     "<<_exename);
  DBG_INFO1 ("log file:     "<<_logname);
  DBG_INFO1 ("cfg file:     "<<_cfgname);
  DBG_INFO1 ("cfg version:  v"<< ver[0]<<"."<<ver[1]<<"."<<ver[2]);

  if (omp)
    if (enthreads)
      Omp::Initialize (threads);
    else
      Omp::Initialize (_cfg);
}

void Code::Finalize ()
{
  Mpi::Finalize ();
}
