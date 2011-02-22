/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdfcell.h
 * @brief  This class represents distribution function stored on regular
 *         rectangular grid.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RECTDFCELL_H__
#define __SAT_RECTDFCELL_H__

#include "simul/field/field.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief This class represents distribution function stored on regular
 *        rectangular grid.
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class RectDistFunction
{
public:
  /// Constructor
  //  RectDistFunction ();
  /// Destructor
  //  ~RectDistFunction ();

  void Initialize (const Vector<int,D> &ncell,
		   const Vector<T,D> &vmin, const Vector<T,D> &vmax);

  void Reset ();

  bool Update (const Vector<T,D> &vel);

  const Field<T,D>* GetData () const
  { return &_df; }

private:
  Vector<T,D> _vmin, _vmax, _dvxi;
  Field<T,D> _df;
};

/// @}

#endif /* __SAT_RECTDFCELL_H__ */
