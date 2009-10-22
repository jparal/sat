/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   range.h
 * @brief  Range of two indicies
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RANGE_H__
#define __SAT_RANGE_H__

/// @addtogroup simul_misc
/// @{

/**
 * @brief Range of two indicies
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
class Range
{
public:
  /// Constructor
  Range ()
  { Initialize (); }

  Range (int i0)
  { Initialize (i0); }

  Range (int i0, int i1)
  { Initialize (i0, i1); }

  Range (const Range &range)
  { Initialize (range); }

  void Initialize ();
  void Initialize (int i0);
  void Initialize (int i0, int i1);
  void Initialize (const Range &range);

  int Length () const
  { return 1+_hi-_lo; // if (_dirty) UpdateLength (); return _len;
  }

  int Low () const
  { return _lo; }

  int Lo () const
  { return _lo; }

  int Hi () const
  { return _hi; }

  int& Lo ()
  { // _dirty = true;
    return _lo; }

  int& Hi ()
  { // _dirty = true;
    return _hi; }

private:
  // void UpdateLength ()
  // { _len = 1+_hi-_lo; _dirty = false; }

  int _lo, _hi;
  //, _len;
  //  bool _dirty;
};

/// @}

#endif /* __SAT_RANGE_H__ */
