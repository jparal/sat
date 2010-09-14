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

#define DEFINE_STDMATH_FNC1(name,fn_double,fn_float,fn_ldouble) \
  template <class T> inline                                     \
  T name (T v)                                                  \
  { return (T)fn_double ((double)v); }                          \
                                                                \
  template <> inline                                            \
  float name (float v)                                          \
  { return fn_float (v); }                                      \
                                                                \
  template <> inline                                            \
  double name (double v)                                        \
  { return fn_double (v); }

#define DEFINE_STDMATH_FNC2(name,fn_double,fn_float,fn_ldouble) \
  template <class T> inline                                     \
  T name (T v1, T v2)                                           \
  { return (T)fn_double ((double)v1, (double)v2); }             \
                                                                \
  template <> inline                                            \
  float name (float v1, float v2)                               \
  { return fn_float (v1, v2); }                                 \
                                                                \
  template <> inline                                            \
  double name (double v1, double v2)				\
  { return fn_double (v1, v2); }

namespace Math {
DEFINE_STDMATH_FNC1(Abs,   fabs,   fabsf,  fabsl)
DEFINE_STDMATH_FNC1(Ceil,  ceil,   ceilf,  ceill)
DEFINE_STDMATH_FNC1(Floor, floor,  floorf, floorl)

DEFINE_STDMATH_FNC1(Sqrt,  sqrt,   sqrtf,  sqrtl)
DEFINE_STDMATH_FNC1(Exp,   exp,    expf,   expl)
DEFINE_STDMATH_FNC1(Ln,    log,    logf,   logl)
DEFINE_STDMATH_FNC1(Log,   log,    logf,   logl)
DEFINE_STDMATH_FNC1(Log10, log10,  log10f, log10l)
DEFINE_STDMATH_FNC2(Pow,   pow,    powf,   powl)

DEFINE_STDMATH_FNC1(Sin,   sin,   sinf,   sinl)
DEFINE_STDMATH_FNC1(Cos,   cos,   cosf,   cosl)
DEFINE_STDMATH_FNC1(Tan,   tan,   tanf,   tanl)
DEFINE_STDMATH_FNC1(Tanh,  tanh,  tanhf,  tanhl)

DEFINE_STDMATH_FNC1(ASin,  asin,  asinf,  asinl)
DEFINE_STDMATH_FNC1(ACos,  acos,  acosf,  acosl)
DEFINE_STDMATH_FNC1(ATan,  atan,  atanf,  atanl)
DEFINE_STDMATH_FNC2(ATan2, atan2, atan2f, atan2l)
};
