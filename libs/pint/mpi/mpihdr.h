/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mpihdr.h
 * @brief  Simple wrapper around mpi.h file to avoid including C++ part
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_MPIHDR_H__
#define __SAT_MPIHDR_H__

#include "satconfig.h"

/// @addtogroup pint_mpi
/// @{

#ifdef HAVE_MPI
#  define _MPICC_H          // HPMPI
#  define MPI_NO_CPPBIND    // SgiMPI
#  define MPICH_SKIP_MPICXX // MPICH2
#  define OMPI_SKIP_MPICXX  // OpenMPI

// A little trick how do decieve LAM/MPI
#  ifdef HAVE_LAM_CONFIG_H
#    include <lam_config.h>
#    ifdef LAM_WANT_MPI2CPP
#      undef LAM_WANT_MPI2CPP
#      define LAM_WANT_MPI2CPP 0
#    endif
#  endif

#  include <mpi.h>
#endif

/// @}

#endif /* __SAT_MPIHDR_H__ */
