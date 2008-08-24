/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fmanip.h
 * @brief  File/directory manipulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FMANIP_H__
#define __SAT_FMANIP_H__

#include <sys/types.h>
#include <sys/stat.h>
#include "base/common/string.h"

/** @addtogroup io_misc
 *  @{
 */

/**
 * @brief File/directory manipulation
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class IO
{
public:
  /**
   * Create the directory specified by the path string.  Permissions are set by
   * default to rwx by user.  The intermediate directories in the path are
   * created if they do not already exist.
   */
  static void Mkdir (const String &path,
		     mode_t mode = (S_IRUSR|S_IWUSR|S_IXUSR));

  /// Rename a file from old file name to new file name.
  static void Rename (const String &oldname,
		      const String &newname);
};

/** @} */

#endif /* __SAT_FMANIP_H__ */
