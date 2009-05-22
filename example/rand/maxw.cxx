/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sigmund.cxx
 * @brief  Example of using Sigmund distribution
 * @author @jparal
 *
 * @revision{0.3.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"
#include "stdlib.h"

int main (int argc, char **argv)
{
  MaxwellRandGen<double> maxw;
  maxw.Initialize (1.);

  for (int i=0; i<1000000; i++)
    printf ("%lf\n", maxw.Get ());
}
