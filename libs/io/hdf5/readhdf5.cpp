/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   readhdf5.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/10, @jparal}
 * @revmessg{Initial version}
 */


#include "base/sys/inline.h"
#include "simul/field/cartstencil.h"
#include "pint/mpi/streammpi.h"

#ifdef HAVE_HDF5
#include <hdf5.h>
#include "hdf5types.h"
#endif

template<class T, int D>
void HDF5File::Read (Field<T,D> &fld,
		     Centring center,
		     const char *tag, const char *fname)
{
}


template<class T, int R, int D>
void HDF5File::Read (Field<Vector<T,R>,D> &fld,
		     Centring center,
		     const char *tag, const char *fname)
{
}
