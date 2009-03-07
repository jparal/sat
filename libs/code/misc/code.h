/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   code.h
 * @brief  Base class of codes
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CODE_H__
#define __SAT_CODE_H__

#include "satbase.h"

/** @addtogroup code_misc
 *  @{
 */

/**
 * @brief Base class of codes.
 *
 * This class supports the following features:
 *  - configuration file name decisions
 *  - log file name decisions
 *  - executable file name decisions
 *  - configuration file initialization
 *  - holding @p argc and @p argv parameters
 *
 * @revision{1.0}
 * @reventry{2008/12, @root}
 * @revmessg{Initial version}
 */
class Code
{
public:
  /// Constructor
  Code ();
  /// Destructor
  ~Code ();

  void Initialize (int *pargc, char ***pargv, bool enmpi);

  bool IsInitialized () const
  { return _initialized; }

  int GetAgrc () const
  { return _argc; }

  char** GetArgv () const
  { return _argv; }

  const String& GetExeName () const
  { return _exename; }

  const String& GetLogName () const
  { return _logname; }

  const String& GetCfgName () const
  { return _cfgname; }

  ConfigFile& GetCfgFile ()
  { return _cfg; }

  const ConfigFile& GetCfgFile () const
  { return _cfg; }

  satversion_t GetCfgVersion () const
  { return _ver; }

private:
  ConfigFile _cfg;
  satversion_t _ver;

  int _argc;
  char **_argv;
  String _exename;
  String _logname;
  String _cfgname;
  bool _initialized;
};

/** @} */

#endif /* __SAT_CODE_H__ */
