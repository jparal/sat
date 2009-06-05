/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   convert.cxx
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#include "convert.h"
#include "satbase.h"

template <class T>
UnitsConvert<T>::UnitsConvert ()
{
  _btime = false;
  _blength = false;
}

template <class T>
T UnitsConvert<T>::Length (T length, bool inv) const
{
  SAT_DBG_ASSERT (_blength);

  if (!inv)
    return length * _length;
  else
    return length / _length;
}

template <class T>
T UnitsConvert<T>::Time (T time, bool inv) const
{
  SAT_DBG_ASSERT (_btime);

  if (!inv)
    return time * _time;
  else
    return time / _time;
}

template <class T>
T UnitsConvert<T>::Speed (T speed, bool inv) const
{
  SAT_DBG_ASSERT (_blength);
  SAT_DBG_ASSERT (_btime);

  if (!inv)
    return speed * _length / _time;
  else
    return speed * _time / _length;
}

template <class T>
T UnitsConvert<T>::Accel (T accel, bool inv) const
{
  SAT_DBG_ASSERT (_blength);
  SAT_DBG_ASSERT (_btime);

  if (!inv)
    return accel * _length / (_time*_time);
  else
    return accel * (_time*_time) / _length;
}

template <class T>
void UnitsConvert<T>::SetLength (T length, bool inv)
{
  _blength = true;
  if (!inv)
    _length = length;
  else
    _length = (T)1./length;
}

template <class T>
void UnitsConvert<T>::SetTime (T time, bool inv)
{
  _btime = true;
  if (!inv)
    _time = time;
  else
    _time = (T)1./time;
}

template class UnitsConvert<float>;
template class UnitsConvert<double>;
