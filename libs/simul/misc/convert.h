/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   convert.h
 * @brief  Convert units.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CONVERT_H__
#define __SAT_CONVERT_H__

/// @addtogroup simul_misc
/// @{

/**
 * @brief Convert units.
 *
 * @revision{1.1}
 * @reventry{2009/05, @jparal}
 * @revmessg{Initial version}
 */
template <class T>
class UnitsConvert
{
public:
  /// Constructor
  UnitsConvert ();

  T Length (T length, bool inv = false) const;
  T Time (T time, bool inv = false) const;
  T Speed (T speed, bool inv = false) const;
  T Accel (T accel, bool inv = false) const;

  /// @name Set conversion constant.
  /// Set the conversion constant for the given unit so the conversion is done
  /// by output unit = input unit * constant.
  /// @{

  void SetLength (T length, bool inv = false);
  void SetTime (T time, bool inv = false);

  /// @}

private:
  T _length; bool _blength;
  T _time;   bool _btime;
};

/// @}

#endif /* __SAT_CONVERT_H__ */
