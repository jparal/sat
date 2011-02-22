/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdflist.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class T, int DP, int DV>
void DistFunctionList<T,DP,DV>::Initialize (const Vector<int,DV> &ncell,
					    const Vector<T,DV> &vmin,
					    const Vector<T,DV> &vmax)
{
  _ncell = ncell;
  _vmin = vmin;
  _vmax = vmax;
}

template<class T, int DP, int DV>
void DistFunctionList<T,DP,DV>::AddDF (const Vector<int,DP> &ic,
				       const Vector<int,DP> &nc)
{
  TDistFuncInfo *dfnfo = new DistFuncInfo<T,DP,DV>;
  dfnfo->df.Initialize (_ncell, _vmin, _vmax);
  dfnfo->ic = ic;
  dfnfo->nc = nc;

  _dfs.PushNew (dfnfo);
}

template<class T, int DP, int DV>
int DistFunctionList<T,DP,DV>::GetDistFncIndex (const Vector<T,DP> &pos) const
{
  Vector<int,DP> loc;
  for (int i=0; i<DP; ++i)
    loc[i] = Math::Floor (pos[i]);

  for (int i=0; i<_dfs.GetSize (); ++i)
  {
    TDistFuncInfo *dfnfo = _dfs.Get (i);

    if (loc == dfnfo->ic)
      return i;
  }

  return -1;
}

template<class T, int DP, int DV>
bool DistFunctionList<T,DP,DV>::Update (int idx, const Vector<T,DV> &vel)
{
  SAT_DBG_ASSERT (0 <= idx && idx < _dfs.GetSize ());

  _dfs.Get (idx)->df.Update (vel);
}

template<class T, int DP, int DV>
bool DistFunctionList<T,DP,DV>::Update (const Vector<T,DP> &pos,
					const Vector<T,DV> &vel)
{
  int idx = GetDistFncIndex (pos);

  if (idx >= 0)
    return Update (idx, vel);

  return false;
}

template<class T, int DP, int DV>
void DistFunctionList<T,DP,DV>::Write (HDF5File &file, const char *tag) const
{
  for (int idf=0; idf<_dfs.GetSize (); ++idf)
  {
    TDistFuncInfo *dfnfo = _dfs.Get (idf);
    String stag = tag;

    for (int i=0; i<DP; ++i)
    {
      stag += "_";
      stag += dfnfo->nc[i] + dfnfo->ic[i];
    }
    file.Write (*(dfnfo->df.GetData ()), stag);
  }
}
