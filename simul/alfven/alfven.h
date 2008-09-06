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
    // NewMemTrackerModule ();
  };
  /// Destructor
  virtual ~AlfvenCAMCode ()
  {
    //    FreeMemTrackerModule ();
  };

  // void DnInitAdd (TSpecie *sp, ScaField &dn)
  // {
  //   int nx = dn.Size (1);
  //   for (int i=0; i<nx; ++i)
  //     dn(i) = (T)1.0 + 0.1 * Math::Sin (2. * M_2PI * (T)i / (nx-1));
  // }

  // void BInitAdd (VecField &b)
  // {
  //   int nx = b.Size (1);
  //   for (int i=0; i<nx; ++i)
  //     b(i)[1] += 0.1 * Math::Sin (2. * M_2PI * (T)i / (nx-1));
  // }

private:
};

#endif /* __SAT_ALFVEN_CAM_H__ */
