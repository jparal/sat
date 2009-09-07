/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cartstencil.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "base/common/meta.h"

template<class T, int D> SAT_INLINE_FLATTEN
void CartStencil::Average (const Field<T,D> &fld,
			   const DomainIterator<D> &iter,
			   T &val)
{
  Vector<T,MetaPow<2,D>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  val = adj.Sum ();
  val *= MetaInv<MetaPow<2,D>::Is>::Is;
}


template<class T> SAT_INLINE_FLATTEN
void CartStencil::Grad (const Field<T,1> &fld,
			const DomainIterator<1> &iter,
			Vector<T,3> &val)
{
  Vector<T,MetaPow<2,1>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  val[0] = fld.GetMesh().GetResolInv (0) * (adj[1] - adj[0]);
  val[1] = 0.;
  val[2] = 0.;
}

template<class T> SAT_INLINE_FLATTEN
void CartStencil::Grad (const Field<T,2> &fld,
			const DomainIterator<2> &iter,
			Vector<T,3> &val)
{
  Vector<T,MetaPow<2,2>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  val[0] = fld.GetMesh().GetResolInvH(0) *
    (adj[1] + adj[3] - adj[0] - adj[2]);
  val[1] = fld.GetMesh().GetResolInvH (1) *
    (adj[2] + adj[3] - adj[0] - adj[1]);
  val[2] = 0.;
}

template<class T> SAT_INLINE_FLATTEN
void CartStencil::Grad (const Field<T,3> &fld,
			const DomainIterator<3> &iter,
			Vector<T,3> &val)
{
  Vector<T,MetaPow<2,3>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  val[0] = fld.GetMesh().GetResolInvQ (0) *
    (adj[1] + adj[3] + adj[5] + adj[7] - adj[0] - adj[2] - adj[4] - adj[6]);
  val[1] = fld.GetMesh().GetResolInvQ (1) *
    (adj[2] + adj[3] + adj[6] + adj[7] - adj[0] - adj[1] - adj[4] - adj[5]);
  val[2] = fld.GetMesh().GetResolInvQ (2) *
    (adj[4] + adj[5] + adj[6] + adj[7] - adj[0] - adj[1] - adj[2] - adj[3]);
}

template<class T> SAT_INLINE_FLATTEN
void CartStencil::Curl (const Field<Vector<T,3>,1> &fld,
			const DomainIterator<1> &iter,
			Vector<T,3> &val)
{
  Vector<Vector<T,3>,MetaPow<2,1>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  T deydx = fld.GetMesh().GetResolInv (0) * (adj[1][1] - adj[0][1]);
  T dezdx = fld.GetMesh().GetResolInv (0) * (adj[1][2] - adj[0][2]);
  val[0] = 0.;
  val[1] = -dezdx;
  val[2] =  deydx;
}

template<class T> SAT_INLINE_FLATTEN
void CartStencil::Curl (const Field<Vector<T,3>,2> &fld,
			const DomainIterator<2> &iter,
			Vector<T,3> &val)
{
  Vector<Vector<T,3>,MetaPow<2,2>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  T deydx = fld.GetMesh().GetResolInvH (0) *
    (adj[1][1] + adj[3][1] - adj[0][1] - adj[2][1]);
  T dezdx = fld.GetMesh().GetResolInvH (0) *
    (adj[1][2] + adj[3][2] - adj[0][2] - adj[2][2]);
  T dexdy = fld.GetMesh().GetResolInvH (1) *
    (adj[2][0] + adj[3][0] - adj[0][0] - adj[1][0]);
  T dezdy = fld.GetMesh().GetResolInvH (1) *
    (adj[2][2] + adj[3][2] - adj[0][2] - adj[1][2]);
  val[0] = dezdy;
  val[1] =       - dezdx;
  val[2] = deydx - dexdy;
}

template<class T> SAT_INLINE_FLATTEN
void CartStencil::Curl (const Field<Vector<T,3>,3> &fld,
			const DomainIterator<3> &iter,
			Vector<T,3> &val)
{
  Vector<Vector<T,3>,MetaPow<2,3>::Is> adj;
  fld.GetAdj (iter.GetLoc (), adj);
  T deydx = fld.GetMesh().GetResolInvQ (0) *
    (adj[1][1] + adj[3][1] + adj[5][1] + adj[7][1] -
     adj[0][1] - adj[2][1] - adj[4][1] - adj[6][1]);
  T dezdx = fld.GetMesh().GetResolInvQ (0) *
    (adj[1][2] + adj[3][2] + adj[5][2] + adj[7][2] -
     adj[0][2] - adj[2][2] - adj[4][2] - adj[6][2]);
  T dexdy = fld.GetMesh().GetResolInvQ (1) *
    (adj[2][0] + adj[3][0] + adj[6][0] + adj[7][0] -
     adj[0][0] - adj[1][0] - adj[4][0] - adj[5][0]);
  T dezdy = fld.GetMesh().GetResolInvQ (1) *
    (adj[2][2] + adj[3][2] + adj[6][2] + adj[7][2] -
     adj[0][2] - adj[1][2] - adj[4][2] - adj[5][2]);
  T deydz = fld.GetMesh().GetResolInvQ (2) *
    (adj[4][1] + adj[5][1] + adj[6][1] + adj[7][1] -
     adj[0][1] - adj[1][1] - adj[2][1] - adj[3][1]);
  T dexdz = fld.GetMesh().GetResolInvQ (2) *
    (adj[4][0] + adj[5][0] + adj[6][0] + adj[7][0] -
     adj[0][0] - adj[1][0] - adj[2][0] - adj[3][0]);
  val[0] = dezdy - deydz;
  val[1] = dexdz - dezdx;
  val[2] = deydx - dexdy;
}

template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeight (const Field<T,D> &fld,
				  const Vector<T2,D> &pos,
				  T &val)
{
  BilinearWeightCache<T2,D> cache;
  FillCache (pos, cache);
  CartStencil::BilinearWeight (fld, cache, val);
}


template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeight (const Field<T,D> &fld,
				  const Vector<T2,D> &pos,
				  BilinearWeightCache<T2,D> &cache,
				  T &val)
{
  FillCache (pos, cache);
  CartStencil::BilinearWeight (fld, cache, val);
}


template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeight (const Field<T,D> &fld,
				  const BilinearWeightCache<T2,D> &cache,
				  T &val)
{
  // Vector<T,MetaPow<2,D>::Is> adj;
  // fld.GetAdj (cache.ipos, adj);
  // val = adj[0] * cache.weight[0];
  // for (int i=1; i<MetaPow<2,D>::Is; ++i)
  //   val += adj[i] * cache.weight[i];
  Vector<T,MetaPow<2,D>::Is> adj;
  fld.GetAdj (cache.ipos, adj);
  adj[0] *= cache.weight[0];
  val = adj[0];
  for (int i=1; i<MetaPow<2,D>::Is; ++i)
  {
    adj[i] *= cache.weight[i];
    val += adj[i];
  }
}


template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeightAdd (Field<T,D> &fld,
				     const Vector<T2,D> &pos,
				     const T &val)
{
  BilinearWeightCache<T2,D> cache;
  FillCache (pos, cache);
  CartStencil::BilinearWeightAdd (fld, cache, val);
}

template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeightAdd (Field<T,D> &fld,
				     const Vector<T2,D> &pos,
				     BilinearWeightCache<T2,D> &cache,
				     const T &val)
{
  FillCache (pos, cache);
  CartStencil::BilinearWeightAdd (fld, cache, val);
}

template<class T, class T2, int D> SAT_INLINE_FLATTEN
void CartStencil::BilinearWeightAdd (Field<T,D> &fld,
				     const BilinearWeightCache<T2,D> &cache,
				     const T &val)
{
  Vector<T,MetaPow<2,D>::Is> adj;
  for (int i=0; i<MetaPow<2,D>::Is; ++i)
  {
    adj[i] = val;
    adj[i] *= cache.weight[i];
  }
  fld.AddAdj (cache.ipos, adj);
}
