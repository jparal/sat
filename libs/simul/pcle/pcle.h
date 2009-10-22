/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pcle.h
 * @brief  Particle class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PCLE_H__
#define __SAT_PCLE_H__

#include <ostream>
#include "pint/satmpi.h"
#include "satmath.h"

/// @addtogroup simul_pcle
/// @{

/**
 * @brief Particle class
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
struct Particle
{
  Vector<T,D> pos;
  Vector<T,3> vel;

  friend std::ostream& operator<< (std::ostream &os,
				   const Particle<T,D> &pcle)
  { os << pcle.pos << ": " << pcle.vel; return os; }
};

// template<class T, int D>
// MpiOStream<T>& operator<< (MpiOStream<T> &os, const Particle<T,D> &pcle)
// { os << pcle.pos << pcle.vel; return os; }

// template<class T, int D>
// MpiIStream<T>& operator>> (MpiOStream<T> &is, const Particle<T,D> &pcle)
// { is >> pcle.pos >> pcle.vel; return is; }

/// @}

#endif /* __SAT_PCLE_H__ */
