/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   privutil.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-03-04, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include <stdlib.h>

template<class T, int D>
void Field<T,D>::Alloc (int dim)
{
  _havegrid = false;
  for (int i=dim; i<D; ++i) _len[i] = _len[dim-1];
  UpdateStride ();

  if (_data != NULL)
    delete[] _data;

  _data = NULL;
  _data = new T[_tot];
  SAT_ASSERT (_data != NULL);
}

template<class T, int D>
void Field<T,D>::Free ()
{
  if (_data != NULL)
    delete[] _data;

  _data = NULL;

  for (int i=0; i<D; ++i)
  {
    _len[i] = 0;
    _str[i] = 0;
  }
  _tot = 0;
  _havegrid = false;
}

template<class T, int D>
void Field<T,D>::UpdateStride ()
{
  _tot = 1;
  for (int i=0; i<D; ++i)
  {
    _str[i] = _tot;
    _tot *= _len[i];
  }
}

template<class T, int D>
template<class T2>
void Field<T,D>::UpdateMeta (const Field<T2,D>& val)
{
  SAT_DBG_ASSERT (_data != val._data);

  if (_len != val._len) _len = val._len;
  if (_tot != val._tot)
    Alloc (D);
  else
    for (int i=0; i<D; ++i) _str[i] = val._str[i];

  _havegrid = val._havegrid;
  if (_havegrid)
  {
    _mesh = val._mesh;
    _layout = val._layout;
  }
}

template<class T, int D>
void Field<T,D>::InitIterator (DomainIterator<D> &iter, Domain<D> &dom,
			       bool omitLast) const
{
  if (omitLast)
    dom.HiAdd (-1);

  if (HaveGrid ())
  {
    Vector<double,D> origin;

    for (int i=0; i<D; ++i)
    {
      int nghz = _layout.GetGhost (i);
      int pos = _layout.GetDecomp().GetPosition(i);
      int len = _len[i] - 2*nghz - (_mesh.Center () == Node ? 1 : 0);

      double orig = double(-nghz) + (_mesh.Center () == Cell ? 0.5 : 0.);
      origin[i] =  orig + double(pos * len);
    }

    iter.Initialize (dom, origin, _mesh.Resol ());
  }
  else
  {
    iter.Initialize (dom);
  }
}
