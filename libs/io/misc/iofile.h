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

/// @addtogroup io_misc
/// @{

/**
 * @brief Base class for all file formats
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

/// @}

#endif /* __SAT_IOFILE_H__ */
