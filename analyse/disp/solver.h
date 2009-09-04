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
    int ksamp; ///< Sample of k we are computing.
  };

  static double DispRelation (double x, void *params);
  int Solve ();

  void Initialize (int argc, char **argv)
  { cfg.Initialize (argc, argv); }

/**
 *
 *
 * @param cfg Configuration of dispersion solver.
 * @param sp Specie index.
 * @param n Order of zeta parameter of Z function.
 * @param is Sample (i.e. sample of k vector)
 * @param w Complex omega
 *
 * @return Z function
 */
  static complex<double> CompZ (const ConfigDisp& cfg, int sp, int n,
				int sample, complex<double> w);

  /// Constructor
  Solver () {};
  /// Destructor
  ~Solver () {};

private:
  ConfigDisp cfg;
};

/// @}

#endif /* __SAT_SOLVER_H__ */