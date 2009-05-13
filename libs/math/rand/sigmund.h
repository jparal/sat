/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sigmund.h
 * @brief  Sigmund distribution function generator
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_SIGMUND_H__
#define __SAT_RAND_SIGMUND_H__

#include "arms.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Sigmund distribution function generator.
 * Generate Sigmund distribution [Sigmund 1969] defined as follows
 * @f[
 * f_s (E_e,T_m) = \frac{E_e}{(E_e + E_b)^3} \times
 * \left[ 1 - \left( \frac{E_e + E_b}{T_m} \right)^{1/2} \right]
 * @f]
 *
 * where @f E_e @f is the energy of ejecta, @f E_b @f is the binding energy
 * and @f T_m @f is transmitted energy from the collision of two particles with
 * mass m1 and m2 and incident energy @f E_i @f defined as:
 *
 * @f[ T_m = E_i \frac{4 m_1 m_2}{(m_1 + m_2)^2} @f]
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
class SigmundRandGen : public ARMSRandGen
{
public:
  typedef ARMSRandGen TBase;

  /// Constructor
  SigmundRandGen ();

  /// Evaluate DF at the point @p x.
  virtual double EvalDF (double x);

  /**
   * @brief Initialize Sigmund distribution function.
   * To get the actual value from the distribution, call Get() function which
   * is defined in ARMSRandGen class. Binding energy is usually in the range of
   * 1-4 eV and transmitted energy in the range of thousands of electron volts.
   *
   * @param bind Binding energy of particle
   * @param trans Transmitted energy from the collision
   */
  void Initialize (double bind, double trans);

  /// Return binding energy
  double GetBindEnergy ()const
  { return _bind; }

  /// Return transmitted energy after the collision
  double GetTransmitEnergy ()const
  { return _trans; }

private:
  double _bind;  ///< Binding energy of particle
  double _trans; ///< Transmitted energy from the collision
  double _cnorm; ///< Normalization constant
  bool _initialized;
};

/// @}

#endif /* __SAT_RAND_SIGMUND_H__ */
