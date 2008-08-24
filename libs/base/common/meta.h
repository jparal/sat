/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   meta.h
 * @brief  Meta loops utils
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_META_H__
#define __SAT_META_H__

/** @addtogroup base_common
 *  @{
 */

/// Meta loops utils
template <int N>
struct MetaLoops
{
  template <class T>
  static inline void Copy (T* dest, const T* src)
  {
    dest[N-1] = src[N-1];
    MetaLoops<N-1>::Copy (dest, src);
  }

  template <class T>
  static inline T Dot (const T * a, const T * b)
  {
    return *a * *b + MetaLoops<N-1>::Dot (a+1,b+1);
  }
};

template <>
struct MetaLoops<1>
{
  template <class T>
  static inline void Copy(T* dest, const T* src)
  {
    dest[0] = src[0];
  }

  template <class T>
  static inline T Dot(const T * a, const T * b)
  {
    return *a * *b;
  }
};

template<int N, int D>
struct MetaPow
{
  enum { Is = N * MetaPow<N,D-1>::Is };
};

template<int N>
struct MetaPow<N,1>
{
  enum { Is = N };
};

template<int I>
struct MetaInv
{
  static const double Is;
};

/** @} */

#endif /* __SAT_META_H__ */
