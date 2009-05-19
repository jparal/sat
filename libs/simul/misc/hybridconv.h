/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hybridconv.h
 * @brief  SI to hybrid units converter.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_HYBRIDCONV_H__
#define __SAT_HYBRIDCONV_H__

#include "convert.h"
#include "satbase.h"

/// @addtogroup simul_misc
/// @{

/**
 * @brief SI to hybrid units converter.
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class SIHybridUnitsConvert : public UnitsConvert<T>
{
public:
  /// Constructor
  //SIHybridUnitsConvert ();
  /// Destructor
  //~SIHybridUnitsConvert ();

  /**
   * @brief Initialize converter.
   *
   * @param b0 Magnetic field of SW in [nT] (at Mercury 20-50 nT).
   * @param n0 Solar wind density in [cm^-3] (at Mercury 30-73 cm^-3).
   */
  void Initialize (T b0, T n0);

  /**
   * @brief Read configuration from config entry.
   * Read magnetic field 'b0' [nT] and density 'n0' [cm^-3] from configuration
   * entry.
   */
  void Initialize (const ConfigEntry &cfg);

private:
};

/// @}

#endif /* __SAT_HYBRIDCONV_H__ */
