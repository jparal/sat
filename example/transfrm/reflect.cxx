/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   reflect.cxx
 * @brief  Specular reflection on the sphere.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/08, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"

typedef Vector<double,3> TVector;

int main (int argc, char **argv)
{
  double rad = 1;
  double dt = 0.3;

  TVector xp0 (-0.9, 0.7, 0.);
  TVector vp  (0.9, -0.1, 0);
  TVector xp = xp0 + dt*vp;

  double a = vp[0]*vp[0] + vp[1]*vp[1];
  double b = -2.*(xp[0]*vp[0] + xp[1]*vp[1]);
  double c = xp[0]*xp[0] + xp[1]*xp[1] - rad*rad;
  double dtc = (-b + Math::Sqrt(b*b - 4.*a*c))/(2.*a);

  TVector xpc = xp - dtc*vp;
  DBG_INFO ("xpc: "<<xpc);

  double phiz = atan2(xpc[0],xpc[1]);

  ZRotMatrix3<double> rotz (phiz);
  ReversibleTransform<double> trans (rotz, xpc);
  DBG_INFO ("Rotz1: "<<rotz.Row1 ());
  DBG_INFO ("Rotz2: "<<rotz.Row2 ());
  DBG_INFO ("Rotz3: "<<rotz.Row3 ());

  TVector xp1;
  xp1 = trans.Other2This (xp);
  xp1[1] = -xp1[1];
  xp1 = trans.This2Other (xp1);
  DBG_INFO ("xp1: "<<xp1);

  TVector vp1;
  vp1 = trans.Other2ThisRelative (vp);
  vp1[1] = -vp1[1];
  vp1 = trans.This2OtherRelative (vp1);
  DBG_INFO ("vp1: "<<vp1);

  // DBG_INFO ("O2T: "<<trans.Other2ThisRelative (xp));
  // DBG_INFO ("T2O: "<<trans.This2OtherRelative (xp));
}
