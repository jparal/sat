/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   iofile.h
 * @brief  base class for all IO file classes providing configuration
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/10, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_IOFILE_H__
#define __SAT_IOFILE_H__

#include "base/sys/satver.h"
#include "base/common/refcount.h"
#include "base/cfgfile/cfgfile.h"
#include "simul/field/field.h"

/** @addtogroup io_misc
 *  @{
 */

/**
 * @brief Base class for all file formats
 *
 * @page cfgfile_iofile IOFile configure format
 * Configure file format accepted:
 * @anchor cfg_io
 * @code
 * output:
 * {
 *   format:
 *   {
 *     type = "TYPE";    // stw | xdmf | hdf5 (default: xdmf)
 *     version = 1;      // no use for now (default: 1)
 *     parallel = false; // do output in parallel? (default: false)
 *     compress =
 *     {
 *       gz = 6;         // 0-9, 0 turns off zlib support (default: 6)
 *       shuffle = true; // to the byte shuffle? (default: true)
 *     };
 *   };
 * };
 * @endcode
 *
 * @sa @ref cfg_cam
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class IOFile : public RefCount
{
public:
  IOFile ();
  void Initialize ();
  void Initialize (bool parallel, int gz, bool shuffle);
  void Initialize (const ConfigEntry &cfg);
  void Initialize (const ConfigFile &cfg);

protected:
  bool _parallel;               /**< Do the I/O operations parallel? */
  int _gz;                      /**< Use zlib compression library? (0-9) */
  bool _shuffle;                /**< Use byte shuffle as well? (HDF5) */
  //  int _version;                     /**< File format version */
};

/** @} */

#endif /* __SAT_IOFILE_H__ */
