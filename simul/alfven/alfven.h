/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   alfven.h
 * @brief  Alfven wave CAM simulation class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ALFVEN_CAM_H__
#define __SAT_ALFVEN_CAM_H__

#include "sat.h"

/**
 * @brief Alfven wave CAM simulation class
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class AlfvenCAMCode : public CAMCode<AlfvenCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<AlfvenCAMCode<T,D>,T,D> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;

  /// Constructor
  AlfvenCAMCode ()
  {
    _nperiod = 4;
    _amp = 0.1;
    // NewMemTrackerModule ();
  };
  /// Destructor
  virtual ~AlfvenCAMCode ()
  {
    //    FreeMemTrackerModule ();
  };

  void BulkInitAdd (TSpecie *sp, VecField &U)
  {
    int nx = U.Size (0);
    int ny = U.Size (1);
    int ghostx = U.GetLayout ().GetGhost (0);
    T dx = U.GetMesh ().GetSpacing (0);
    int ipx = U.GetLayout ().GetDecomp ().GetPosition (0);
    int npx = U.GetLayout ().GetDecomp ().GetSize (0);
    T kx = (M_2PI * (T)_nperiod) / ((T)((nx - 2*ghostx) * npx) * dx);

    for (int j=0; j<ny; ++j)
      for (int i=0; i<nx; ++i)
      {
	T x = (T)(i - ghostx + ipx * nx);
	U(i,j)[1] = - _amp * Math::Cos (kx * x);
	U(i,j)[2] = + _amp * Math::Sin (kx * x);
      }
  }

  void BInitAdd (VecField &b)
  {
    int nx = b.Size (0);
    int ny = b.Size (1);
    T dx = b.GetMesh ().GetSpacing (0);
    int ipx = b.GetLayout ().GetDecomp ().GetPosition (0);
    int npx = b.GetLayout ().GetDecomp ().GetSize (0);
    T kx = (M_2PI * (T)_nperiod) / ((T)(nx * npx) * dx);

    for (int j=0; j<ny; ++j)
      for (int i=0; i<nx; ++i)
      {
	T x = (T)(i + ipx * nx);
	b(i,j)[1] += _amp * Math::Cos (kx * x);
	b(i,j)[2] -= _amp * Math::Sin (kx * x);
      }
  }

private:
  int _nperiod;
  T _amp;
};

#endif /* __SAT_ALFVEN_CAM_H__ */
