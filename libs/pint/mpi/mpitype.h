/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mpitype.h
 * @brief  Template class definitions of MPI types
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_MPITYPE_H__
#define __SAT_MPITYPE_H__

#include "mpihdr.h"
#include "math/algebra/vector.h"

template<class T, int D> class Vector;

/// @addtogroup pint_mpi
/// @{

#ifndef HAVE_MPI
#  define MPI_Datatype int

#  define MPI_CHAR 0
#  define MPI_UNSIGNED_CHAR 1
#  define MPI_SHORT 2
#  define MPI_UNSIGNED_SHORT 3
#  define MPI_INT 4
#  define MPI_UNSIGNED 5
#  define MPI_LONG 6
#  define MPI_UNSIGNED_LONG 7
#  define MPI_FLOAT 8
#  define MPI_DOUBLE 9
#  define MPI_LONG_DOUBLE 10
#  define MPI_SIGNED_CHAR 11
#  define MPI_LONG_LONG_INT 12
#  define MPI_UNSIGNED_LONG_LONG 13
#  define MPI_LONG_LONG 14
#  define MPI_FLOAT_INT 15
#  define MPI_DOUBLE_INT 16
#  define MPI_LONG_INT 17
#  define MPI_SHORT_INT 18
#  define MPI_2INT 19
#  define MPI_LONG_DOUBLE_INT 20
#endif

template<class T>
struct MpiType
{
  static MPI_Datatype GetID ();
  static int Rank ();
  struct MpiTypeInt
  {
    T d;
    int i;
  };
};


#define MPITYPE_SPECIALIZE(type, mpitype)			\
  template <>							\
  inline MPI_Datatype MpiType< type >::GetID ()			\
  { return mpitype; }						\
  template <>							\
  inline int MpiType< type >::Rank ()				\
  { return 1; }							\
  template <>							\
  inline MPI_Datatype MpiType< Vector<type,1> >::GetID ()	\
  { return MPI_FLOAT; }						\
  template <>							\
  inline int MpiType< Vector<type,1> >::Rank ()			\
  { return 1; }							\
  template <>							\
  inline MPI_Datatype MpiType< Vector<type,2> >::GetID ()	\
  { return MPI_FLOAT; }						\
  template <>							\
  inline int MpiType< Vector<type,2> >::Rank ()			\
  { return 2; }							\
  template <>							\
  inline MPI_Datatype MpiType< Vector<type,3> >::GetID ()	\
  { return MPI_FLOAT; }						\
  template <>							\
  inline int MpiType< Vector<type,3> >::Rank ()			\
  { return 3; }							\


MPITYPE_SPECIALIZE (char,           MPI_CHAR)
MPITYPE_SPECIALIZE (unsigned char,  MPI_UNSIGNED_CHAR)
MPITYPE_SPECIALIZE (short,          MPI_SHORT)
MPITYPE_SPECIALIZE (unsigned short, MPI_UNSIGNED_SHORT)
MPITYPE_SPECIALIZE (int,            MPI_INT)
MPITYPE_SPECIALIZE (unsigned,       MPI_UNSIGNED)
MPITYPE_SPECIALIZE (long,           MPI_LONG)
MPITYPE_SPECIALIZE (unsigned long,  MPI_UNSIGNED_LONG)
MPITYPE_SPECIALIZE (float,          MPI_FLOAT)
MPITYPE_SPECIALIZE (double,         MPI_DOUBLE)
MPITYPE_SPECIALIZE (long double,    MPI_LONG_DOUBLE)

// Not supported by ISO C++
// MPITYPE_SPECIALIZE (signed char,    MPI_SIGNED_CHAR)
// MPITYPE_SPECIALIZE (long long int, MPI_LONG_LONG_INT)
// MPITYPE_SPECIALIZE (unsigned long long, MPI_UNSIGNED_LONG_LONG)
// MPITYPE_SPECIALIZE (long long, MPI_LONG_LONG)

MPITYPE_SPECIALIZE (MpiType<float>::MpiTypeInt,       MPI_FLOAT_INT)
MPITYPE_SPECIALIZE (MpiType<double>::MpiTypeInt,      MPI_DOUBLE_INT)
MPITYPE_SPECIALIZE (MpiType<long>::MpiTypeInt,        MPI_LONG_INT)
MPITYPE_SPECIALIZE (MpiType<short>::MpiTypeInt,       MPI_SHORT_INT)
MPITYPE_SPECIALIZE (MpiType<int>::MpiTypeInt,         MPI_2INT)
MPITYPE_SPECIALIZE (MpiType<long double>::MpiTypeInt, MPI_LONG_DOUBLE_INT)

// MPITYPE_SPECIALIZE (Vector<float,3>,  MPI_FLOAT)
// MPITYPE_SPECIALIZE (Vector<double,3>, MPI_DOUBLE)

/// @}

#endif /* __SAT_MPITYPE_H__ */
