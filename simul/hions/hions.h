/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   hions.h
 * @brief  Heavy ions Monte-Carlo simulation of Mercury
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_HIONS_H__
#define __SAT_HIONS_H__

#include "sat.h"

#define HIONS_TYPE float

/**
 * @brief Heavy ions Monte-Carlo simulation of Mercury
 *
 * @revision{1.0}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
class HeavyIonsCode : public Code
{
public:
  typedef HIONS_TYPE TType;
  typedef Vector<TType, 3> TVector;
  typedef Field<TVector, 3> TField;
  typedef Particle<TType,3> TParticle;
  typedef CamSpecie<TType,3> TSpecie;

  /// Constructor
  HeavyIonsCode ();
  /// Destructor
  ~HeavyIonsCode ();

  /// Initialize simulation from pointer to the @p argc and @p argv parameters
  /// of the main function.
  void Initialize (int* pargc, char*** pargv);

  /**
   * @brief Load STW file into a Field.
   * Specifically, load a file given by parameter @e path into the vector
   * component @e idx of the vector Field. Variable @e path should be full path
   * to the file including the suffix.
   *
   * @param fld field class reference
   * @param idx index of the vector from the range [0,2]
   * @param path path to the STW file (including gz suffix)
   */
  void Load (TField& fld, int idx, const char* path);

  /// Execute simulation.
  virtual void Exec ();
  /// Single iteration (called from Code::Exec)
  virtual void Iter ();

private:
  String _stwname;
  TField _B, _E;
  TSpecie _mmvNax;

  SimulTime _time;        ///< simulation time
  SensorManager _sensmng; ///< sensor manager
  int _clean;

  Vector<int,3> _nx;
  Vector<TType,3> _dx, _rx;
  TType _scalef, _radius;
};

#endif /* __SAT_HIONS_H__ */
