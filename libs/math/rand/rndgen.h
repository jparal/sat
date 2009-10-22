/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rndgen.h
 * @brief  Random number generator
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-05-28, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_RNDGEN_H__
#define __SAT_RAND_RNDGEN_H__

#include "base/sys/porttypes.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Random number generator.
 * This random number generator originally appeared in "Toward a Universal
 * Random Number Generator" by George Marsaglia and Arif Zaman.  Florida State
 * University Report: FSU-SCRI-87-50 (1987)
 *
 * It was later modified by F. James and published in "A Review of Pseudo-
 * random Number Generators"
 *
 * THIS IS THE BEST KNOWN RANDOM NUMBER GENERATOR AVAILABLE.  (However, a newly
 * discovered technique can yield a period of 10^600. But that is still in the
 * development stage.)
 *
 * It passes ALL of the tests for random number generators and has a period of
 * 2^144, is completely portable (gives bit identical results on all machines
 * with at least 24-bit mantissas in the floating point representation).
 *
 * The algorithm is a combination of a Fibonacci sequence (with lags of 97 and
 * 33, and operation "subtraction plus one, modulo one") and an "arithmetic
 * sequence" (using subtraction).
 *
 * Portable random number generator class.  The reason for using this class if
 * that you may want a consistent random number generator across all platforms
 * supported by Crystal Space. Besides, in general it is a better quality RNG
 * than the one supplied in most C runtime libraries. Personally I observed a
 * significant improvement in a random terrain generator I made after I
 * switched to this RNG.
 *
 * @revision{1.0}
 * @reventry{2008-05-28, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class RandomGen
{
  int i97, j97;
  T u [98];
  T c, cd, cm;

public:
  /// Initialize the random number generator using current time()
  RandomGen ()
  { Initialize (); }
  /// Initialize the random number generator given a seed
  RandomGen (uint32_t iSeed)
  { Initialize (iSeed); }

  /// Initialize the RNG using current time() as the seed value
  void Initialize ();
  /// Select the random sequence number (942,438,978 sequences available)
  void Initialize (uint32_t iSeed);

  /// Get a floating-point random number in range 0 <= num < 1
  T Get ()
  { return RANMAR (); }

  /// Get a uint32_t integer random number in range 0 <= num < iLimit
  uint32_t Get (uint32_t iLimit);

  /// Perform a self-test
  bool SelfTest ();

private:
  /// Initialize the random number generator
  void InitRANMAR (uint32_t ij, uint32_t kl);
  /// Get the next random number in sequence
  T RANMAR ();
};

/// @}

#endif /* __SAT_RAND_RNDGEN_H__ */
