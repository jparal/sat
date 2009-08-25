/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filexdmf.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "satconfig.h"
#include "filehdf5.h"

#ifdef HAVE_HDF5
#include "writehdf5.cpp"
#include "readhdf5.cpp"
#else
#include "fakehdf5.cpp"
#endif

#define SPECIALIZE_H5F_WR_ARRS(type)					\
  template /*<class type>*/						\
  void HDF5File::Write<> (const Array<type>&, const char*,		\
			  const char*, bool);

#define SPECIALIZE_H5F(type)			\
  SPECIALIZE_H5F_WR_ARRS(type)

SPECIALIZE_H5F(float)
SPECIALIZE_H5F(double)
SPECIALIZE_H5F(unsigned int)    //< Due to the DistFnc sensor
