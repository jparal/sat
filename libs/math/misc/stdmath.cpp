/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   stdmath.cpp
 * @brief  Standart math functions
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/08, @jparal}
 * @revmessg{Initial version}
 */

#define DEFINE_STDMATH_FNC(name,fn_double,fn_float,fn_ldouble)  \
  template <class T> inline                                     \
  T Math::name (T v)						\
  { return (T)fn_double ((double)v); }                          \
                                                                \
  template <> inline                                            \
  float Math::name (float v)					\
  { return fn_float (v); }                                      \
								\
  template <> inline                                            \
  double Math::name (double v)					\
  { return fn_double (v); }

#define DEFINE_STDMATH_FNC2(name,fn_double,fn_float,fn_ldouble) \
  template <class T> inline                                     \
  T Math::name (T v1, T v2)					\
  { return (T)fn_double ((double)v1, (double)v2); }             \
                                                                \
  template <> inline                                            \
  float Math::name (float v1, float v2)				\
  { return fn_float (v1, v2); }                                 \
                                                                \
  template <> inline                                            \
  double Math::name (double v1, double v2)			\
  { return fn_double (v1, v2); }

DEFINE_STDMATH_FNC(Abs,   fabs,  fabsf,  fabsl)
DEFINE_STDMATH_FNC(Ceil,  ceil,  ceilf,  ceill)
DEFINE_STDMATH_FNC(Floor, floor, floorf, floorl)

DEFINE_STDMATH_FNC(Sqrt,  sqrt,  sqrtf,  sqrtl)
DEFINE_STDMATH_FNC(Ln,    log,   logf,   logl)
DEFINE_STDMATH_FNC(Log,   log,   logf,   logl)
DEFINE_STDMATH_FNC(Log10, log10, log10f, log10l)
DEFINE_STDMATH_FNC2(Pow,  pow,   powf,   powl)

DEFINE_STDMATH_FNC(Sin    ,sin,  sinf,   sinl)
DEFINE_STDMATH_FNC(Cos    ,cos,  cosf,   cosl)
DEFINE_STDMATH_FNC(Tan    ,tan,  cosf,   tanl)

DEFINE_STDMATH_FNC(ASin   ,asin, asinf,  asinl)
DEFINE_STDMATH_FNC(ACos   ,acos, acosf,  acosl)
DEFINE_STDMATH_FNC(ATan   ,atan, acosf,  atanl)
