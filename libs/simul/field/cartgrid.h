/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cartgrid.h
 * @brief  Cartesian grid.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-02, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CARTGRID_H__
#define __SAT_CARTGRID_H__

// #include "flditer.h"

/** @addtogroup simul_field
 *  @{
 */

/**
 * @brief Uniform Cartesian grid.
 * This grid suppose that all cells have the same size
 *
 * @revision{1.0}
 * @reventry{2008-06-02, @jparal}
 * @revmessg{Initial version}
 */
// template<class T, int D>
// class CartesianGrid
// {
// public:
//   /// Constructor
//   CartesianGrid ();
//   /// Destructor
//   ~CartesianGrid ();
//   /// Initialize grid
//   void Initialize (const Vector<T,D>& size);

//   const Vector<T,3>& Curl (const Field<Vector<T,3>,D> &fld,
// 			   const FieldIter<D> &it) const;

// private:
//   T _dxi;
//   T _dyi;
//   T _dzi;
// };

// template<class T>
// class CartesianGrid<T,1>
// {
//   const Vector<T,3>& Curl (const Field<Vector<T,3>,1> &fld,
// 			   const FieldIter<1> &it) const
//   {
//     // const Vector<T,3> &v0 = fld(it.ix);
//     // const Vector<T,3> &v1 = fld(it.ixp1);
//     // T dvydx = _dxi * (fld(it._ip1[0]).y - fld(it._i[0].y));
//     // return Vector<T,3> (0.,-dvzdx,dvydx);
//   }
// };

// template<class T>
// class CartesianGrid<T,2>
// {
//   const Vector<T,3>& Curl (const Field<Vector<T,3>,2> &fld,
// 			   const FieldIter<2> &it) const
//   {
//   }
// };

// template<class T>
// class CartesianGrid<T,3>
// {
//   const Vector<T,3>& Curl (const Field<Vector<T,3>,3> &fld,
// 			   const FieldIter<3> &it) const
//   {
//   }
// };

/** @} */

#endif /* __SAT_CARTGRID_H__ */
