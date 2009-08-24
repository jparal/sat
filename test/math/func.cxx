/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   plasmafnc.cxx
 * @brief  Test of plasma dispersion function.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "sat.h"

#define epsilon 1.e-6

using namespace std;

#define CHECK_ME(value)				\
  CHECK_CLOSE (0., real(value), epsilon);	\
  CHECK_CLOSE (0., imag(value), epsilon);

SUITE (MathFunctionSuite)
{
  TEST (PlasmaFncTest)
  {
    complex<double> value;

    value = Math::FncZ (complex<double>(1.991466835,-1.354810123));
    CHECK_ME (value);
    value = Math::FncZ (complex<double>(1.991466835,-1.354810123));
    CHECK_ME (value);
    value = Math::FncZ (complex<double>(2.691149024,-2.177044906));
    CHECK_ME (value);
    value = Math::FncZ (complex<double>(3.235330868,-2.784387613));
    CHECK_ME (value);
    value = Math::FncZ (complex<double>(3.697309702,-3.287410789));
    CHECK_ME (value);
    value = Math::FncZ (complex<double>(4.106107271,-3.725948729));
    CHECK_ME (value);
  }
}
