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

#define SPECIALIZE_H5F_RD_FLDS(type,dim)				\
  template /*<class type, int dim>*/					\
  void HDF5File::Read<> (Field<type,dim>&,				\
			 Centring, const char*, const char*);

#define SPECIALIZE_H5F_FLD(type,dim)		\
  SPECIALIZE_H5F_RD_FLDS(type,dim)

#define SPECIALIZE_H5F(type)					\
  SPECIALIZE_H5F_FLD(type,1)					\
  SPECIALIZE_H5F_FLD(type,2)					\
  SPECIALIZE_H5F_FLD(type,3)					\
  SPECIALIZE_H5F_FLD(type,4)					\
  SPECIALIZE_H5F_FLD(type,5)					\
  SPECIALIZE_H5F_FLD(type,6)

SPECIALIZE_H5F(float)
SPECIALIZE_H5F(double)
SPECIALIZE_H5F(unsigned int)    //< Due to the DistFnc sensor
