/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   satver.h
 * @brief  Version manipulation macros.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/02, @jparal}
 * @revmessg{Initial version}
 * @reventry{2009/04, @jparal}
 * @revmessg{add SAT_VERSION_CODE_.. macros dealing with current code version}
 */

#ifndef __SAT_SATVER_H__
#define __SAT_SATVER_H__

#include "satconfig.h"
#include "porttypes.h"

/** @addtogroup base_sys
 *  @{
 */

/// Version type
typedef uint32_t satversion_t;

/// Generate SAT version ID from major, minor and micro version numbers
#define SAT_VERSION_MAKE(major,minor,micro)		\
  ((((satversion_t)(major)) << 24) |                    \
   (((satversion_t)(minor)) << 12) |                    \
   (((satversion_t)(micro))))

/// Current SAT code version
#define SAT_VERSION_CODE						\
  SAT_VERSION_MAKE(SAT_VERSION_MAJOR, SAT_VERSION_MINOR, SAT_VERSION_MICRO)

/// Extracts \e Major version number from version ID
#define SAT_VERSION_GET_MAJOR(version)		\
  (((version) & 0xFF000000) >> 24)
/// Extracts \e Minor version number from version ID
#define SAT_VERSION_GET_MINOR(version)		\
  (((version) & 0x00FFF000) >> 12)
/// Extracts \e Micro version number from version ID
#define SAT_VERSION_GET_MICRO(version)		\
  (((version) & 0x00000FFF))

/// Check whether version ID is \emph{less then} given version
#define SAT_VERSION_LT(ver,major,minor,micro)   \
  (ver < SAT_VERSION_MAKE(major,minor,micro))
/// Check whether version ID is \emph{greater then} given version
#define SAT_VERSION_GT(ver,major,minor,micro)   \
  (ver > SAT_VERSION_MAKE(major,minor,micro))
/// Check whether version ID is \emph{less or equal then} given version
#define SAT_VERSION_LE(ver,major,minor,micro)   \
  (ver <= SAT_VERSION_MAKE(major,minor,micro))
/// Check whether version ID is \emph{greater or equal then} given version
#define SAT_VERSION_GE(ver,major,minor,micro)   \
  (ver >= SAT_VERSION_MAKE(major,minor,micro))
/// Check whether version ID is \emph{with in (including)} given versions
#define SAT_VERSION_IN(ver,majorl,minorl,microl,majorh,minorh,microh)   \
  (SAT_VERSION_GE(ver,majorl,minorl,microl) &&                          \
   SAT_VERSION_LE(ver,majorh,minorh,microh))

/// Check whether CURRENT version ID is \emph{less then} given version
#define SAT_VERSION_CODE_LT(major,minor,micro)		\
  SAT_VERSION_LT(SAT_VERSION_CODE,major,minor,micro)
/// Check whether CURRENT version ID is \emph{greater then} given version
#define SAT_VERSION_CODE_GT(major,minor,micro)		\
  SAT_VERSION_GT(SAT_VERSION_CODE,major,minor,micro)
/// Check whether CURRENT version ID is \emph{less or equal then} given version
#define SAT_VERSION_CODE_LE(major,minor,micro)		\
  SAT_VERSION_LE(SAT_VERSION_CODE,major,minor,micro)
/// Check whether CURRENT version ID is \emph{greater or equal then} given
/// version
#define SAT_VERSION_CODE_GE(major,minor,micro)		\
  SAT_VERSION_GE(SAT_VERSION_CODE,major,minor,micro)
/// Check whether CURRENT version ID is \emph{with in (including)} given
/// versions
#define SAT_VERSION_CODE_IN(majorl,minorl,microl,majorh,minorh,microh)	\
  SAT_VERSION_IN(SAT_VERSION_CODE,majorl,minorl,microl,majorh,minorh,microh)

/** @} */

#endif /* __SAT_SATVER_H__ */
