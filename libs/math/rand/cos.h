/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cos.h
 * @brief  Cos distribution function
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_COS_H__
#define __SAT_RAND_COS_H__

#include "rndgen.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Cos distribution function
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class CosRandGen : public RandomGen<T>
{
public:
  /// Constructor
  CosRandGen ()
  { Initialize (); }

  void Initialize ();

  T Get ();

private:
};

/// @}

#endif /* __SAT_RAND_COS_H__ */
