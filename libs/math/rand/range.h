/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   range.h
 * @brief  Uniform range generator.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_RANGE_H__
#define __SAT_RAND_RANGE_H__

#include "rndgen.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Uniform range generator.
 *
 * @revision{1.0}
 * @reventry{2009/03, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class RangeRandGen : public RandomGen<T>
{
public:
  /// Constructor
  /// default values: min=0, max=1
  RangeRandGen ()
  { Initialize ((T)0., (T)1.); }

  // Constructor
  RangeRandGen (T min, T max)
  { Initialize (min, max); }

  /**
   * Initialization function (default uniform distribution on the range
   * [min,max])
   * @param min minimal value
   * @param max maximal value
   */
  void Initialize (T min, T max);

  T GetMin () const
  { return _min; }

  T GetMax () const
  { return _max; }

  /// Return value from the range [min,max]
  T Get ();

private:
  T _min, _max, _diff;
};

/// @}

#endif /* __SAT_RAND_RANGE_H__ */
