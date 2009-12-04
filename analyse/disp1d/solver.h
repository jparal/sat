/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   solver.h
 * @brief  Solver of dispersion relation.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SOLVER_H__
#define __SAT_SOLVER_H__

#include "cfgdisp.h"
#include <gsl/gsl_vector.h>

/// @addtogroup analyse
/// @{

/**
 * @brief Solver of dispersion relation.
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */
class Solver
{
public:

  struct SolverParams
  {
    ConfigDisp *cfg;
    double kvec; ///< k vector.
    bool lpol; ///< Polarization.
    double imw, rew; ///< Used for initial guess (previous values)
  };

  static int DispRelation (const gsl_vector *x, void *params, gsl_vector *f);

  int Solve (SolverParams *params, complex<double> &root);

  void SolveAll ();

  void Print ();

  void Initialize (int argc, char **argv)
  { _cfg.Initialize (argc, argv); }

  /// Constructor
  Solver () {};
  /// Destructor
  ~Solver () {};

private:
  ConfigDisp _cfg;
};

/// @}

#endif /* __SAT_SOLVER_H__ */
