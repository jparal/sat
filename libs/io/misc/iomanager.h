/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   iomanager.h
 * @brief  Input/Output manager
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_IOMANAGER_H__
#define __SAT_IOMANAGER_H__

#include "base/satcfgfile.h"
#include "base/common/string.h"
#include "simul/satfield.h"
#include "simul/sensor/rectdflist.h"
#include "io/sathdf5.h"

template<class T, int DP, int DV>
class DistFunctionList;

/// @addtogroup io_misc
/// @{

enum IOFormat
{
  //  IO_FORMAT_STW,
  IO_FORMAT_HDF5,
  IO_FORMAT_XDMF
};

/**
 * @brief Input/Output manager
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class IOManager
{
public:
  /// Constructor
  IOManager ();
  /// Destructor
  ~IOManager ();

  void Initialize (IOFormat format, String runname, String dir);
  void Initialize (const ConfigEntry &cfg);

  /**
   * Initialize IO manager.
   * The accepted configuration file is:
   * @code
   * output:
   * {
   *   format:
   *   {
   *     type    = "xdmf"; // [default: "hdf5"]
   *     dir     = "out";  // [default: ""]
   *     runname = "test";
   *   };
   * };
   * @endcode
   *
   * @param cfg configuration file
   */
  void Initialize (const ConfigFile &cfg);

  String GetFileName (const char *tag, const SimulTime &stime) const;
  String GetFileName (const char *tag) const;

  template<class T, int D>
  void Write (Field<T,D> &fld, const SimulTime &stime, const char *tag);

  template<class T, int DP, int DV>
  void Write (DistFunctionList<T, DP, DV> &dfl, const SimulTime &stime,
	      const char *tag);

  String GetDir () const
  {
    String dir = _dir;
    return dir;
  }

private:
  IOFormat _format;
  IOFile *_file;
  String _runname;
  String _dir;
};

#include "iomanager.cpp"

/// @}

#endif /* __SAT_IOMANAGER_H__ */
