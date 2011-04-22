/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   advfld.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::AdvField (T dt)
{
  T dtb = dt / ((T) _nsub);
  T tbh = (T)0.5 * dtb;

  /******************************/
  /* Advance B to t = t + dt!   */
  /******************************/
  CalcE (_B, _Ua, _dna);
  CalcB (tbh, _Psi, _Bh);
  //  CalcPsi (dth, _B, _Psih);

  for (int step=1; step<_nsub; ++step)
  {
    CalcE (_Bh, _Ua, _dna);
    CalcB (dtb, _Psih, _B);
    //    CalcPsi (dtb, _Bh, _Psi);
    CalcE (_B,  _Ua, _dna);
    CalcB (dtb, _Psi, _Bh);
    //    CalcPsi (dtb, _B, _Psih);
  }

  CalcE (_Bh, _Ua, _dna);
  CalcB (dtb, _Psih, _B);
  //  CalcPsi (dtb, _Bh, _Psi);

  CalcE (_B,  _Ua, _dna);
  CalcB (tbh, _Psi, _Bh);
  //  CalcPsi (dth, _B, _Psi);
}
