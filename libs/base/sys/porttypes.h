/**
 * @file porttypes.h
 * @brief Portable int types across platforms
 *
 * inttypes.h is part of the POSIX and C99 specs, but in practice support for
 * it varies wildly across systems. We need a totally portable way to
 * unambiguously get the fixed-bit-width integral types, and this file provides
 * that via the following typedefs:
 *
 * - int8_t, uint8_t      signed/unsigned 8-bit integral types
 * - int16_t, uint16_t    signed/unsigned 16-bit integral types
 * - int32_t, uint32_t    signed/unsigned 32-bit integral types
 * - int64_t, uint64_t    signed/unsigned 64-bit integral types
 * - intptr_t, uintptr_t  signed/unsigned types big enough to hold any pointer
 *   offset
 *
 * In general, it uses the system inttypes.h when it's known to be available,
 * (as reported by configure via a previously-included config.h file),
 * otherwise it uses configure-detected sizes for the types to try and auto
 * construct the types. Some specific systems with known issues are handled
 * specially.
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version imported from GASNet (http://)}
 */

#ifndef __SAT_PORTTYPES_H__
#define __SAT_PORTTYPES_H__

#include "satconfig.h"
#include "platform.h"

#ifndef _INTTYPES_DEFINED
#  define _INTTYPES_DEFINED
  /* first, check for the easy and preferred case - if configure reports that a
     standards-compliant system header is available, then use it */
#  if defined(HAVE_INTTYPES_H)
#    include <inttypes.h>
#  elif defined(HAVE_STDINT_H)
#    include <stdint.h>
#  elif defined(HAVE_SYS_TYPES_H)
#    include <sys/types.h>
    /* next, certain known systems are handled specially */
    /* MS Visual C++ */
#  elif defined(PLATFORM_ARCH_MSWINDOWS) && defined(PLATFORM_COMPILER_MICROSOFT)
    typedef signed __int8      int8_t;
    typedef unsigned __int8   uint8_t;
    typedef __int16           int16_t;
    typedef unsigned __int16 uint16_t;
    typedef __int32           int32_t;
    typedef unsigned __int32 uint32_t;
    typedef __int64           int64_t;
    typedef unsigned __int64 uint64_t;

    typedef          int     intptr_t;
    typedef unsigned int    uintptr_t;
    /* Cray's UnicOS */
#  elif defined(PLATFORM_OS_UNICOS)
    /* oddball architecture lacking a 16-bit type */
#    define INTTYPES_16BIT_MISSING 1
    typedef signed char        int8_t;
    typedef unsigned char     uint8_t;
    typedef short             int16_t; /* This is 32-bits, should be 16 !!! */
    typedef unsigned short   uint16_t; /* This is 32-bits, should be 16 !!! */
    typedef short             int32_t;
    typedef unsigned short   uint32_t;
    typedef int               int64_t;
    typedef unsigned int     uint64_t;

    typedef          int     intptr_t;
    typedef unsigned int    uintptr_t;
#  elif defined(PLATFORM_OS_MTA)
#    include <sys/types.h>
    typedef u_int8_t          uint8_t;
    typedef u_int16_t        uint16_t;
    typedef u_int32_t        uint32_t;
    typedef u_int64_t        uint64_t;
    typedef int64_t          intptr_t;
    typedef u_int64_t       uintptr_t;
#  elif defined(PLATFORM_OS_SUPERUX)
#    include <sys/types.h> /* provides int32_t and uint32_t - use to prevent conflict */
    typedef signed char        int8_t;
    typedef unsigned char     uint8_t;
    typedef short             int16_t;
    typedef unsigned short   uint16_t;
    typedef long              int64_t;
    typedef unsigned long    uint64_t;

    typedef          long    intptr_t;
    typedef unsigned long   uintptr_t;
#  elif defined(PLATFORM_OS_FAMILYNAME)
    /* what a mess -
       inttypes.h and stdint.h are incomplete or missing on
       various versions of cygwin, with no easy way to check */
#    ifdef HAVE_INTTYPES_H
#      include <inttypes.h>
#    endif
#    ifdef HAVE_STDINT_H
#      include <stdint.h>
#    endif
#    ifdef HAVE_SYS_TYPES_H
#      include <sys/types.h>
#    endif
#    ifndef __uint32_t_defined
      typedef u_int8_t     uint8_t;
      typedef u_int16_t   uint16_t;
      typedef u_int32_t   uint32_t;
      typedef u_int64_t   uint64_t;
#    endif
#    ifndef __intptr_t_defined
      typedef          int     intptr_t;
      typedef unsigned int    uintptr_t;
#    endif
#  elif defined(SIZEOF_CHAR) && \
        defined(SIZEOF_SHORT) && \
        defined(SIZEOF_INT) && \
        defined(SIZEOF_LONG) && \
        defined(SIZEOF_LONG_LONG) && \
        defined(SIZEOF_VOID_P)
      /* configure-detected integer sizes are available, so use those to
       * automatically detect the sizes system headers may typedef some subset
       * of these, so we cannot safely use typedefs here so use macros instead
       */
      /* first include the system headers if we know we have them, to try and
       * avoid conflicts
       */
#    ifdef HAVE_INTTYPES_H
#      include <inttypes.h>
#    endif
#    ifdef HAVE_STDINT_H
#      include <stdint.h>
#    endif
#    ifdef HAVE_SYS_TYPES_H
#      include <sys/types.h>
#    endif

#    if SIZEOF_CHAR == 1
        typedef signed   char  _pit_int8_t;
        typedef unsigned char _pit_uint8_t;
#    else
#      error Cannot find an 8-bit type for your platform
#    endif

#    if SIZEOF_CHAR == 2
        typedef signed   char  _pit_int16_t;
        typedef unsigned char _pit_uint16_t;
#    elif SIZEOF_SHORT == 2
        typedef          short  _pit_int16_t;
        typedef unsigned short _pit_uint16_t;
#    elif SIZEOF_INT == 2
        typedef          int  _pit_int16_t;
        typedef unsigned int _pit_uint16_t;
#    else
#      error Cannot find a 16-bit type for your platform
#    endif

#    if SIZEOF_SHORT == 4
        typedef          short  _pit_int32_t;
        typedef unsigned short _pit_uint32_t;
#    elif SIZEOF_INT == 4
        typedef          int  _pit_int32_t;
        typedef unsigned int _pit_uint32_t;
#    elif SIZEOF_LONG == 4
        typedef          long  _pit_int32_t;
        typedef unsigned long _pit_uint32_t;
#    else
#      error Cannot find a 32-bit type for your platform
#    endif

#    if SIZEOF_INT == 8
        typedef          int  _pit_int64_t;
        typedef unsigned int _pit_uint64_t;
#    elif SIZEOF_LONG == 8
        typedef          long  _pit_int64_t;
        typedef unsigned long _pit_uint64_t;
#    elif SIZEOF_LONG_LONG == 8
        typedef          long long  _pit_int64_t;
        typedef unsigned long long _pit_uint64_t;
#    else
#      error Cannot find a 64-bit type for your platform
#    endif

#    if SIZEOF_VOID_P == SIZEOF_SHORT
        typedef          short  _pit_intptr_t;
        typedef unsigned short _pit_uintptr_t;
#    elif SIZEOF_VOID_P == SIZEOF_INT
        typedef          int  _pit_intptr_t;
        typedef unsigned int _pit_uintptr_t;
#    elif SIZEOF_VOID_P == SIZEOF_LONG
        typedef          long  _pit_intptr_t;
        typedef unsigned long _pit_uintptr_t;
#    elif SIZEOF_VOID_P == SIZEOF_LONG_LONG
        typedef          long long  _pit_intptr_t;
        typedef unsigned long long _pit_uintptr_t;
#    else
#      error Cannot find a integral pointer-sized type for your platform
#    endif

#    define  int8_t    _pit_int8_t
#    define uint8_t   _pit_uint8_t
#    define  int16_t   _pit_int16_t
#    define uint16_t  _pit_uint16_t
#    define  int32_t   _pit_int32_t
#    define uint32_t  _pit_uint32_t
#    define  int64_t   _pit_int64_t
#    define uint64_t  _pit_uint64_t
#    define  intptr_t  _pit_intptr_t
#    define uintptr_t _pit_uintptr_t
#  else
    /* no information available, so try inttypes.h and hope for the best
       if we die here, the correct fix is to detect the sizes using configure
       (and include *config.h before this file).
     */
#    include <inttypes.h>
#  endif
#endif /* _INTTYPES_DEFINED */

#endif /* __SAT_PORTTYPES_H__ */
