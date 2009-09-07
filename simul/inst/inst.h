/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   ioncyclo.h
 * @brief  Ioncyclo wave CAM simulation class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_IONCYCLO_CAM_H__
#define __SAT_IONCYCLO_CAM_H__

#include "sat.h"

/**
 * @brief Instability CAM simulation class
 *
 * Initialization is now dimension independent
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/03, @jparal}
 * @revmessg{initialization is now dimension independent}
 * @revmessg{print configuration of wave setup}
 */
template<class T, int D>
class InstabilityCAMCode : public CAMCode<InstabilityCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<InstabilityCAMCode<T,D>,T,D> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef Particle<T,D> TParticle;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;
};

#endif /* __SAT_IONCYCLO_CAM_H__ */
