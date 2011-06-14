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
  double vth = 1.;
  int nsamp = 10;

  if (argc >= 2)
    vth = atof (argv[1]);
  if (argc >= 3)
    nsamp = atoi (argv[2]);

  MaxwellRandGen<double> maxw;
  maxw.Initialize (vth);

  for (int i=0; i<nsamp; i++)
    printf ("%+.20lf\n", maxw.Get ());
}
