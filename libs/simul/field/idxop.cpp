/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   idxop.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-03-04, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "base/common/meta.h"

#define _ASSERT_IDX0(i0)			\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0])
#define _ASSERT_IDX1(i0,i1)			\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0]);		\
  SAT_DBG_ASSERT (0<=i1 && i1<_len[1])
#define _ASSERT_IDX2(i0,i1,i2)			\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0]);		\
  SAT_DBG_ASSERT (0<=i1 && i1<_len[1]);		\
  SAT_DBG_ASSERT (0<=i2 && i2<_len[2])
#define _ASSERT_IDX3(i0,i1,i2,i3)		\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0]);		\
  SAT_DBG_ASSERT (0<=i1 && i1<_len[1]);		\
  SAT_DBG_ASSERT (0<=i2 && i2<_len[2]);		\
  SAT_DBG_ASSERT (0<=i3 && i3<_len[3])
#define _ASSERT_IDX4(i0,i1,i2,i3,i4)		\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0]);		\
  SAT_DBG_ASSERT (0<=i1 && i1<_len[1]);		\
  SAT_DBG_ASSERT (0<=i2 && i2<_len[2]);		\
  SAT_DBG_ASSERT (0<=i3 && i3<_len[3]);		\
  SAT_DBG_ASSERT (0<=i4 && i4<_len[4])
#define _ASSERT_IDX5(i0,i1,i2,i3,i4,i5)		\
  SAT_DBG_ASSERT (0<=i0 && i0<_len[0]);		\
  SAT_DBG_ASSERT (0<=i1 && i1<_len[1]);		\
  SAT_DBG_ASSERT (0<=i2 && i2<_len[2]);		\
  SAT_DBG_ASSERT (0<=i3 && i3<_len[3]);		\
  SAT_DBG_ASSERT (0<=i4 && i4<_len[4]);		\
  SAT_DBG_ASSERT (0<=i5 && i5<_len[5])

/************************************/
/* Constant versions of operator () */
/************************************/

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0) const
{
  SAT_CASSERT (D == 1);
  _ASSERT_IDX0 (i0);
  return _data[i0*_str[0]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0, int i1) const
{
  SAT_CASSERT (D == 2);
  _ASSERT_IDX1 (i0,i1);
  return _data[i0*_str[0] + i1*_str[1]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0, int i1, int i2) const
{
  SAT_CASSERT (D == 3);
  _ASSERT_IDX2 (i0,i1,i2);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0, int i1, int i2, int i3) const
{
  SAT_CASSERT (D == 4);
  _ASSERT_IDX3 (i0,i1,i2,i3);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0, int i1, int i2, int i3, int i4) const
{
  SAT_CASSERT (D == 5);
  _ASSERT_IDX4 (i0,i1,i2,i3,i4);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3] + i4*_str[4]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T&
Field<T,D>::operator() (int i0, int i1, int i2, int i3, int i4, int i5) const
{
  SAT_CASSERT (D == 6);
  _ASSERT_IDX5 (i0,i1,i2,i3,i4,i5);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3] + i4*_str[4] +
	       i5*_str[5]];
}

/****************************************/
/* Non-constant versions of operator () */
/****************************************/

template<class T, int D> SAT_INLINE_FLATTEN
T&
Field<T,D>::operator() (int i0)
{
  SAT_CASSERT (D == 1);
  _ASSERT_IDX0 (i0);
  return _data[i0*_str[0]];
}

template<class T, int D> SAT_INLINE_FLATTEN
T&
Field<T,D>::operator() (int i0, int i1)
{
  SAT_CASSERT (D == 2);
  _ASSERT_IDX1 (i0,i1);
  return _data[i0*_str[0] + i1*_str[1]];
}

template<class T, int D> SAT_INLINE_FLATTEN
T&
Field<T,D>::operator() (int i0, int i1, int i2)
{
  SAT_CASSERT (D == 3);
  _ASSERT_IDX2 (i0,i1,i2);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2]];
}

template<class T, int D> SAT_INLINE_FLATTEN
T&
Field<T,D>::operator() (int i0, int i1, int i2, int i3)
{
  SAT_CASSERT (D == 4);
  _ASSERT_IDX3 (i0,i1,i2,i3);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3]];
}

template<class T, int D> SAT_INLINE_FLATTEN
T& Field<T,D>::operator() (int i0, int i1, int i2, int i3, int i4)
{
  SAT_CASSERT (D == 5);
  _ASSERT_IDX4 (i0,i1,i2,i3,i4);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3] + i4*_str[4]];
}

template<class T, int D> SAT_INLINE_FLATTEN
T&
Field<T,D>::operator() (int i0, int i1, int i2, int i3, int i4, int i5)
{
  SAT_CASSERT (D == 6);
  _ASSERT_IDX5 (i0,i1,i2,i3,i4,i5);
  return _data[i0*_str[0] + i1*_str[1] + i2*_str[2] + i3*_str[3] + i4*_str[4] +
	       i5*_str[5]];
}

template<class T, int D> SAT_INLINE_FLATTEN
const T& Field<T,D>::operator() (const Vector<int,D> &ii) const
{
  //@todo check dimensions (using metaprogramming should be easy)
  return _data[MetaLoops<D>::Dot (ii._d, _str)];
}

template<class T, int D> SAT_INLINE_FLATTEN
T& Field<T,D>::operator() (const Vector<int,D> &ii)
{
  //@todo check dimensions (using metaprogramming should be easy)
  return _data[MetaLoops<D>::Dot (ii._d, _str)];
}

template<int D> struct IdxUtils
{
  static Vector<int,MetaPow<2,D>::Is> GetOffset (const int *str)
  { SAT_CASSERT (true); return Vector<int,MetaPow<2,D>::Is> (0); }
};

template<> struct IdxUtils<1>
{
  static Vector<int,2> GetOffset (const int *str)
  { return Vector<int,2> (0, str[0]); }
};

template<> struct IdxUtils<2>
{
  static Vector<int,4> GetOffset (const int *str)
  { return Vector<int,4> (0, str[0], str[1], str[0] + str[1]); }
};

template<> struct IdxUtils<3>
{
  static Vector<int,8> GetOffset (const int *str)
  { return Vector<int,8> (0,             str[0],
			  str[1],        str[0]+str[1],
			  str[2],        str[0]+str[2],
			  str[1]+str[2], str[0]+str[1]+str[2]); }
};

template<class T, int D>
template<class T2>
void Field<T,D>::GetAdj (const Vector<T2,D> &loc,
			 Vector<T,MetaPow<2,D>::Is> &adj) const
{
  //  SAT_CASSERT (D == MetaPow<2,D>::Is);
  int idx = MetaLoops<D>::Dot (loc._d, _str);
  Vector<int,MetaPow<2,D>::Is> off = IdxUtils<D>::GetOffset (_str);

  for (int i=0; i<MetaPow<2,D>::Is; ++i)
    adj[i] = _data[idx+off[i]];
}

template<class T, int D>
template<class T2>
void Field<T,D>::AddAdj (const Vector<T2,D> &loc,
			 const Vector<T,MetaPow<2,D>::Is> &adj)
{
  //  SAT_CASSERT (D == MetaPow<2,D>::Is);
  int idx = MetaLoops<D>::Dot (loc._d, _str);
  Vector<int,MetaPow<2,D>::Is> off = IdxUtils<D>::GetOffset (_str);

  SAT_OMP_CRITICAL
    for (int i=0; i<MetaPow<2,D>::Is; ++i)
      _data[idx+off[i]] += adj[i];
}
