/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   field.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-03-03, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "base/sys/assert.h"

template<class T, int D> inline
Field<T,D>::Field ()
  : _data(NULL), _havegrid(false)
{}

template<class T, int D> inline
Field<T,D>::Field (int d0)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0);
}

template<class T, int D> inline
Field<T,D>::Field (int d0, int d1)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0, d1);
}

template<class T, int D> inline
Field<T,D>::Field (int d0, int d1, int d2)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0, d1, d2);
}

template<class T, int D> inline
Field<T,D>::Field (int d0, int d1, int d2, int d3)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0, d1, d2, d3);
}

template<class T, int D> inline
Field<T,D>::Field (int d0, int d1, int d2, int d3, int d4)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0, d1, d2, d3, d4);
}

template<class T, int D> inline
Field<T,D>::Field (int d0, int d1, int d2, int d3, int d4, int d5)
  : _data(NULL), _havegrid(false)
{
  Initialize (d0, d1, d2, d3, d4, d5);
}

template<class T, int D>
template<int VD> inline
Field<T,D>::Field (const Vector<int,VD> &d)
  : _data(NULL), _havegrid(false)
{
  Initialize (d);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0)
{
  _len[0] = d0;
  Alloc (1);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0, int d1)
{
  _len[0] = d0;
  _len[1] = d1;
  Alloc (2);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0, int d1, int d2)
{
  _len[0] = d0;
  _len[1] = d1;
  _len[2] = d2;
  Alloc (3);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0, int d1, int d2, int d3)
{
  _len[0] = d0;
  _len[1] = d1;
  _len[2] = d2;
  _len[3] = d3;
  Alloc (4);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0, int d1, int d2, int d3, int d4)
{
  _len[0] = d0;
  _len[1] = d1;
  _len[2] = d2;
  _len[3] = d3;
  _len[4] = d4;
  Alloc (5);
}

template<class T, int D> inline
void Field<T,D>::Initialize (int d0, int d1, int d2, int d3, int d4, int d5)
{
  _len[0] = d0;
  _len[1] = d1;
  _len[2] = d2;
  _len[3] = d3;
  _len[4] = d4;
  _len[5] = d5;
  Alloc (6);
}

template<class T, int D>
template<int VD> inline
void Field<T,D>::Initialize (const Vector<int,VD> &d)
{
  for (int i=0; i<VD; ++i) _len[i] = d[i];
  Alloc (VD);
}

template<class T, int D> inline
Field<T,D>::~Field ()
{
  Free ();
}

template<class T, int D> inline
Field<T,D>::Field (const Mesh<D> &mesh, const Layout<D> &layout)
{
  Initialize (mesh, layout);
}

template<class T, int D> inline
void Field<T,D>::Initialize (const Mesh<D> &mesh, const Layout<D> &layout)
{
  Initialize (mesh.Dim ());
  _mesh = mesh;
  _layout = layout;
  _havegrid = true;
}
