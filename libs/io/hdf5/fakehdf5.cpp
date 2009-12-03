/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fakehdf5.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/10, @jparal}
 * @revmessg{Initial version}
 */

template<class T, int D>
void HDF5File::Write (const Field<T,D> &fld, const char *tag)
{
  DBG_ERROR ("HDF5File::Write not implemented!!");
}

template<class T, int R, int D>
void HDF5File::Write (const Field<Vector<T,R>,D> &fld, const char *tag)
{
  DBG_ERROR ("HDF5File::Write not implemented!!");
}

template<class T, int D>
void HDF5File::Read (Field<T,D> &fld, const char *tag)
{
  DBG_ERROR ("HDF5File::Read not implemented!!");
}

template<class T, int R, int D>
void HDF5File::Read (Field<Vector<T,R>,D> &fld, const char *tag)
{
  DBG_ERROR ("HDF5File::Read not implemented!!");
}
