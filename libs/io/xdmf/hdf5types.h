/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hdf5types.h
 * @brief  HDF5 type traits
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_HDF5TYPES_H__
#define __SAT_HDF5TYPES_H__

#include "satconfig.h"

#ifdef HAVE_HDF5
#include <hdf5.h>
#endif

/** @addtogroup io_xdmf
 *  @{
 */

#ifdef HAVE_HDF5

template< class T >
struct HDF5TypeTraits
{
  static hid_t GetID ();
  //  { SAT_CASSERT_MSG (false, "Unsupported data type"); }
};

#define HDF5TYPETRAITS_GETID_SPECIALIZE(type, id)	 \
  template <> inline					 \
  hid_t HDF5TypeTraits< type >::GetID ()                 \
  { return id; }

#define HDF5TYPETRAITS_SPECIALIZE(type, id)	    \
  HDF5TYPETRAITS_GETID_SPECIALIZE(type,id)          \

HDF5TYPETRAITS_SPECIALIZE (char,           H5T_NATIVE_CHAR)
HDF5TYPETRAITS_SPECIALIZE (signed char,    H5T_NATIVE_SCHAR)
HDF5TYPETRAITS_SPECIALIZE (unsigned char,  H5T_NATIVE_UCHAR)
HDF5TYPETRAITS_SPECIALIZE (short,          H5T_NATIVE_SHORT)
HDF5TYPETRAITS_SPECIALIZE (unsigned short, H5T_NATIVE_USHORT)
HDF5TYPETRAITS_SPECIALIZE (int,            H5T_NATIVE_INT)
HDF5TYPETRAITS_SPECIALIZE (unsigned,       H5T_NATIVE_UINT)
HDF5TYPETRAITS_SPECIALIZE (long,           H5T_NATIVE_LONG)
HDF5TYPETRAITS_SPECIALIZE (unsigned long,  H5T_NATIVE_ULONG)
HDF5TYPETRAITS_SPECIALIZE (float,          H5T_NATIVE_FLOAT)
HDF5TYPETRAITS_SPECIALIZE (double,         H5T_NATIVE_DOUBLE)

#endif /* HAVE_HDF5 */

/** @} */

#endif /* __SAT_HDF5TYPES_H__ */
