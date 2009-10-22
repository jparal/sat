/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cartstencil.h
 * @brief  Cartesian Stencil
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CARTSTENCIL_H__
#define __SAT_CARTSTENCIL_H__

#include "bwcache.h"
#include "simul/field/field.h"

/// @addtogroup simul_field
/// @{

/**
 * @brief Cartesian Stencil
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class CartStencil
{
public:

  /**
   * Compute average from Field at position at iter and iter+1
   *
   * @param[in] fld Field
   * @param[in] iter DomainIterator
   * @param[out] val average
   */
  template<class T, int D> SAT_INLINE_FLATTEN
  static void Average (const Field<T,D> &fld,
		       const DomainIterator<D> &iter,
		       T &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Grad (const Field<T,1> &fld,
		    const DomainIterator<1> &iter,
		    Vector<T,3> &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Grad (const Field<T,2> &fld,
		    const DomainIterator<2> &iter,
		    Vector<T,3> &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Grad (const Field<T,3> &fld,
		    const DomainIterator<3> &iter,
		    Vector<T,3> &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Curl (const Field<Vector<T,3>,1> &fld,
		    const DomainIterator<1> &iter,
		    Vector<T,3> &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Curl (const Field<Vector<T,3>,2> &fld,
		    const DomainIterator<2> &iter,
		    Vector<T,3> &val);

  template<class T> SAT_INLINE_FLATTEN
  static void Curl (const Field<Vector<T,3>,3> &fld,
		    const DomainIterator<3> &iter,
		    Vector<T,3> &val);

  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeight (const Field<T,D> &fld,
			      const Vector<T2,D> &pos,
			      T &val);

  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeight (const Field<T,D> &fld,
			      const Vector<T2,D> &pos,
			      BilinearWeightCache<T2,D> &cache,
			      T &val);

  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeight (const Field<T,D> &fld,
			      const BilinearWeightCache<T2,D> &cache,
			      T &val);


  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeightAdd (Field<T,D> &fld,
				 const Vector<T2,D> &pos,
				 const T &val);

  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeightAdd (Field<T,D> &fld,
				 const Vector<T2,D> &pos,
				 BilinearWeightCache<T2,D> &cache,
				 const T &val);

  template<class T, class T2, int D> SAT_INLINE_FLATTEN
  static void BilinearWeightAdd (Field<T,D> &fld,
				 const BilinearWeightCache<T2,D> &cache,
				 const T &val);
};

#include "cartstencil.cpp"

/// @}

#endif /* __SAT_CARTSTENCIL_H__ */
