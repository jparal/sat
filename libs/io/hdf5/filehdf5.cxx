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

#define SPECIALIZE_HDF5FILE_WRITE(type,dim)				\
  template /*<class type, int dim>*/					\
  void HDF5File::Write<> (const Field<type,dim>&,			\
			  Centring, const char*, const char*);

#define SPECIALIZE_HDF5FILE_VWRITE(type,dim,vdim)			\
  template /*<class type, int vdim, int dim>*/				\
  void HDF5File::Write<> (const Field<Vector<type,vdim>,dim>&,		\
			  Centring center, const char*, const char*);

#define SPECIALIZE_HDF5FILE_WREAD(type,dim)				\
  template /*<class type, int dim>*/					\
  void HDF5File::Read<> (Field<type,dim>&,				\
			 Centring, const char*, const char*);

#define SPECIALIZE_HDF5FILE_VREAD(type,dim,vdim)			\
  template /*<class type, int vdim, int dim>*/				\
  void HDF5File::Read<> (Field<Vector<type,vdim>,dim>&,			\
			 Centring center, const char*, const char*);

#define SPECIALIZE_HDF5FILE_ALL(type,dim)			\
  SPECIALIZE_HDF5FILE_WRITE(type,dim)				\
  SPECIALIZE_HDF5FILE_VWRITE(type,dim,1)			\
  SPECIALIZE_HDF5FILE_VWRITE(type,dim,2)			\
  SPECIALIZE_HDF5FILE_VWRITE(type,dim,3)			\
  SPECIALIZE_HDF5FILE_WREAD(type,dim)				\
  SPECIALIZE_HDF5FILE_VREAD(type,dim,1)				\
  SPECIALIZE_HDF5FILE_VREAD(type,dim,2)				\
  SPECIALIZE_HDF5FILE_VREAD(type,dim,3)

#define SPECIALIZE_HDF5FILE(type)				\
  SPECIALIZE_HDF5FILE_ALL(type,1)				\
  SPECIALIZE_HDF5FILE_ALL(type,2)				\
  SPECIALIZE_HDF5FILE_ALL(type,3)				\
  SPECIALIZE_HDF5FILE_ALL(type,4)				\
  SPECIALIZE_HDF5FILE_ALL(type,5)				\
  SPECIALIZE_HDF5FILE_ALL(type,6)

SPECIALIZE_HDF5FILE(float)
SPECIALIZE_HDF5FILE(double)
SPECIALIZE_HDF5FILE(unsigned int)    //< Due to the DistFnc sensor
