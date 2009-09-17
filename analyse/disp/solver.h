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
    bool real; ///< Are we solving for a real part?
    bool lpol; ///< Polarization.
    int ksamp; ///< Sample of k we are computing.
  };

  static double DispRelation (double x, void *params);
  int Solve (SolverParams *params, double &root);
  void SolveAll ();

  void Print ();

  void Initialize (int argc, char **argv)
  { cfg.Initialize (argc, argv); }

  /// Constructor
  Solver () {};
  /// Destructor
  ~Solver () {};

private:
  ConfigDisp cfg;
};

/// @}

#endif /* __SAT_SOLVER_H__ */
