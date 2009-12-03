/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   zfnc.cxx
 * @brief  Store Z plasma dispersion function.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"

#define FILE_NAME "output"

int main (int argc, char **argv)
{
  const double zeta_max = 100.;
  const int nzeta = 1000;

  const double dz = zeta_max/(nzeta-1);

  Array<double> imzeta, rezeta, impfnc, repfnc;
  for (int i=0; i<nzeta; ++i)
    for (int j=0; j<nzeta; ++j)
  {
    complex<double> zeta(double(i)*dz, double(j)*dz);
    complex<double> pfnc = Math::FncZ (zeta);

    imzeta.Push (imag(zeta));
    rezeta.Push (real(zeta));
    impfnc.Push (imag(pfnc));
    repfnc.Push (real(pfnc));
  }

  HDF5File file (FILE_NAME);
  file.Write (imzeta, "imzeta");
  file.Write (rezeta, "rezeta");
  file.Write (impfnc, "impfnc");
  file.Write (repfnc, "repfnc");
}
