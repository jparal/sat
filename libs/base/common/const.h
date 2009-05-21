/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   const.h
 * @brief  Mathematical constants
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CONST_H__
#define __SAT_CONST_H__

/** @addtogroup base_common
 *  @{
 */

#undef  M_E
#define M_E             2.7182818284590452354	/**< e          */
#undef  M_LOG2E
#define M_LOG2E         1.4426950408889634074	/**< log_2 e    */
#undef  M_LOG10E
#define M_LOG10E        0.43429448190325182765	/**< log_10 e   */
#undef  M_LN2
#define M_LN2           0.69314718055994530942	/**< log_e 2    */
#undef  M_LN10
#define M_LN10          2.30258509299404568402	/**< log_e 10   */
#undef  M_2PI
#define M_2PI           6.283185307179586477    /**< 2 pi       */
#undef  M_PI
#define M_PI            3.14159265358979323846	/**< pi         */
#undef  M_PI_2
#define M_PI_2          1.57079632679489661923	/**< pi/2       */
#undef  M_PI_4
#define M_PI_4          0.78539816339744830962	/**< pi/4       */
#undef  M_1_PI
#define M_1_PI          0.31830988618379067154	/**< 1/pi       */
#undef  M_2_PI
#define M_2_PI          0.63661977236758134308	/**< 2/pi       */
#undef  M_2_SQRTPI
#define M_2_SQRTPI      1.12837916709551257390	/**< 2/sqrt(pi) */
#undef  M_SQRT2
#define M_SQRT2         1.41421356237309504880	/**< sqrt(2)    */
#undef  M_1_SQRT2
#define M_1_SQRT2       0.70710678118654752440	/**< 1/sqrt(2)  */

#define M_EPS   0.001
#define M_EPSS  0.000001
#define M_EPSSS 0.000000000001

#define M_PHYS_ME 9.10938188e-31   ///< Mass of the electron [kg]
#define M_PHYS_MI 1.67262158e-27   ///< Mass of the proton [kg]
#define M_PHYS_MP 1.67262158e-27   ///< Mass of the proton [kg]
#define M_PHYS_E 1.60217646e-19    ///< Electron charge [C]
#define M_PHYS_MERCURY_GRAV 3.697  ///< Gravitation of Mercury [m/s^2]

/** @} */

#endif /* __SAT_CONST_H__ */
