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
  enum IOS
  {
    write = 0x1,
    read  = 0x2,
    app   = 0x4,  ///< Append data to existing file.
    suff  = 0x8   ///< Add suffix to file name when opening.
  };

  typedef unsigned int Flags;

  IOFile () : RefCount ()
  { Initialize (); }

  void Initialize ();
  void Initialize (int driver, int gz, bool shuffle);
  void Initialize (const ConfigEntry &cfg);
  void Initialize (const ConfigFile &cfg);

  bool Serial () const
  { return _driver <= 0; }

  bool Separate () const
  { return _driver == 1; }

  bool Parallel () const
  { return _driver >= 2; }

  void SetSerial ()
  { _driver = 0; }

  void SetSeparate ()
  { _driver = 1; }

  void SetParallel ()
  { _driver = 2; }

  int GetDriver () const
  { return _driver; }
  void SetDriver (int driver)
  { _driver = driver; }

  int Gzip () const
  { return _gz; }

  bool Shuffle () const
  { return _shuffle; }

  virtual void Open (const char *fname, IOFile::Flags flags) {}
  virtual void Close () {}

private:
  int _driver; ///< Can be: 0:serial, 1:separate, 2:parallel
  int _gz;                      /**< Use zlib compression library? (0-9) */
  bool _shuffle;                /**< Use byte shuffle as well? (HDF5) */
};

/// @}

#endif /* __SAT_IOFILE_H__ */
