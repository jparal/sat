/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rndgen.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-05-28, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "rndgen.h"
#include "pint/satmpi.h"

#include <stdio.h>
#include <time.h>

template<class T>
void RandomGen<T>::Initialize ()
{
  Initialize (time (0) + Mpi::Rank ());
}

template<class T>
void RandomGen<T>::Initialize (uint32_t iSeed)
{
  uint32_t ij = iSeed % 31329UL;
  uint32_t kl = (iSeed / 31329UL) % 30082UL;
  InitRANMAR (ij, kl);
}

template<class T>
void RandomGen<T>::InitRANMAR (uint32_t ij, uint32_t kl)
{
  /*
    This is the initialization routine for the random number generator RANMAR()
    NOTE: The seed variables can have values between:    0 <= IJ <= 31328
                                                         0 <= KL <= 30081
    The random number sequences created by these two seeds are of sufficient
    length to complete an entire calculation with. For example, if several
    different groups are working on different parts of the same calculation,
    each group could be assigned its own IJ seed. This would leave each group
    with 30000 choices for the second seed. That is to say, this random
    number generator can create 900 million different subsequences -- with
    each subsequence having a length of approximately 10^30.
  */

  int i, j, k, l, ii, jj, m;
  T s, t;

  i = (ij / 177) % 177 + 2;
  j = ij % 177 + 2;
  k = (kl / 169) % 178 + 1;
  l = kl % 169;

  for (ii = 1; ii <= 97; ii++)
  {
    s = 0.0;
    t = 0.5;
    for (jj = 1; jj <= 24; jj++)
    {
      m = (((i * j) % 179) * k) % 179;
      i = j;
      j = k;
      k = m;
      l = (53 * l + 1) % 169;
      if ((l * m) % 64 >= 32) s += t;
      t *= 0.5;
    }
    u[ii] = s;
  }

  c = 362436.0 / 16777216.0;
  cd = 7654321.0 / 16777216.0;
  cm = 16777213.0 / 16777216.0;

  i97 = 97;
  j97 = 33;
}

template<class T>
T RandomGen<T>::RANMAR ()
{
  T uni;			/* the random number itself */

  uni = u [i97] - u [j97];	/* difference between two [0..1] numbers */
  if (uni < 0.0) uni += 1.0;
  u [i97] = uni;
  i97--;			/* i97 ptr decrements and wraps around */
  if (i97 == 0) i97 = 97;
  j97--;			/* j97 ptr decrements likewise */
  if (j97 == 0) j97 = 97;
  c -= cd;			/* finally, condition with c-decrement */
  if (c < 0.0) c += cm;		/* cm > cd we hope! (only way c always >0) */
  uni -= c;
  if (uni < 0.0) uni += 1.0;

  return (uni);			/* return the random number */
}

template<class T>
uint32_t RandomGen<T>::Get (uint32_t iLimit)
{
  return int (Get () * iLimit);
}

template<class T>
bool RandomGen<T>::SelfTest ()
{
  /*
    Use IJ = 1802 & KL = 9373 to test the random number generator. The
    subroutine RANMAR should be used to generate 20000 random numbers.
    Then display the next six random numbers generated multiplied by 4096*4096
    If the random number generator is working properly, the random numbers
    should be:
              6533892.0  14220222.0  7275067.0
              6172232.0  8354498.0   10633180.0
  */
  InitRANMAR (1802, 9373);
  int i;
  for (i = 0; i < 20000; i++)
    RANMAR ();
  if ((RANMAR () * 4096 * 4096 != 6533892.0)
   || (RANMAR () * 4096 * 4096 != 14220222.0)
   || (RANMAR () * 4096 * 4096 != 7275067.0)
   || (RANMAR () * 4096 * 4096 != 6172232.0)
   || (RANMAR () * 4096 * 4096 != 8354498.0)
   || (RANMAR () * 4096 * 4096 != 10633180.0))
  {
    puts ("WARNING: The random number generator is not working properly!\n");
    return false;
  }
  return true;
}

template class RandomGen<float>;
template class RandomGen<double>;

