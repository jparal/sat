/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filestw.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-09, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "satmath.h"

using namespace std;

template<int D>
StwFile<D>::StwFile ()
  : _cnt(0)
{
  for (int i=0; i<D; ++i)
  {
    _ofs[i] = NULL;
    _ifs[i] = NULL;
  }
}

template<int D>
void StwFile<D>::Close ()
{
  for (int i=0; i<D; ++i)
  {
    if (_ofs[i])
    {
      delete _ofs[i];
      _ofs[i] = NULL;
    }
    if (_ifs[i])
    {
      delete _ifs[i];
      _ifs[i] = NULL;
    }
  }
}

template<int D>
template<int R>
void StwFile<D>::WriteHeader (const Vector<int,R> &rank)
{
  SAT_ASSERT (_mode & File::Out);

  for (int i=0; i<D; ++i)
  {
    for (int j=0; j<R; ++j)
      *(_ofs[i]) << "  " << rank[j];
    *(_ofs[i]) << "\n";
  }
}

template<int D>
template<class T>
void StwFile<D>::Write (const Vector<T,D> &val)
{
  ++_cnt;
  for (int i=0; i<D; ++i)
    Write (val[i], i);
}

template<int D>
template<class T>
void StwFile<D>::Write (const T &val)
{
  ++_cnt;
  Write (val, 0);
}

template<int D>
template<class T>
void StwFile<D>::Write (const T &val, int is)
{
  SAT_DBG_ASSERT (_mode & File::Out);

  *_ofs[is] << "  " << val;
  if (_cnt % STWFILE_VALUES_PER_LINE == 0)
    *_ofs[is] << "\n";
}


template<int D>
template<int R>
void StwFile<D>::ReadHeader (Vector<int,R> &rank)
{
  SAT_ASSERT (_mode & File::In);

  for (int i=0; i<D; ++i)
  {
    for (int j=0; j<R; ++j)
      *(_ifs[i]) >> rank[j];
  }
}

template<int D>
template<class T>
void StwFile<D>::Read (Vector<T,D> &val)
{
  SAT_DBG_ASSERT (_mode & File::In);

  for (int i=0; i<D; ++i)
    *_ifs[i] >> val[i];
}

template<int D>
template<class T>
void StwFile<D>::Read (T &val)
{
  SAT_DBG_ASSERT (_mode & File::In);

  *_ifs[0] >> val;
}

template<int D>
void StwFile<D>::Open (const char *sensor, const char *name,
		       int mode)
{
  const char *dir[] = {"x", "y", "z"};

  for (int i=0; i<D; ++i)
    Open (sensor, (D == 1 ? "" : dir[i]), name, mode, i);
}

template<int D>
void StwFile<D>::Open (const char *sensor, const char *comp, const char *name,
		       int mode, int is)
{
  _mode = mode;

  String fname;
  fname += sensor;
  fname += comp;
  fname += name;

  // zlib doesn't support an append mode
  bool gz = (mode & File::Gz);
  if (mode & File::App) gz = false;

#ifdef HAVE_ZLIB
  if (gz)
  {
    fname += ".gz";
    if (mode & File::Out)
      _ofs[is] = new ogzstream (fname);
    else
      _ifs[is] = new igzstream (fname);
  }
  else
#endif //HAVE_ZLIB
  {
    if (mode & File::Out)
      _ofs[is] = new ofstream (fname, mode & File::App ? ios::app | ios::out : ios::out);
    else
      _ifs[is] = new ifstream (fname);
  }
}
