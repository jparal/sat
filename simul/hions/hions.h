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
#include "speciehi.h"
#include "utils.h"

/// @addtogroup hions
/// @{

/**
 * @brief Heavy ions Monte-Carlo simulation of Mercury
 *
 * @revision{1.0}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class HeavyIonsCode : public Code
{
public:
  typedef Vector<T,3> TVector;
  typedef Field<TVector,3> TField;
  typedef HISpecie<T> TSpecie;
  typedef RefArray<TSpecie> TSpecieArray;
  typedef typename TSpecie::TParticleArray TParticleArray;
  typedef typename TSpecie::TParticle TParticle;

  /// Constructor
  HeavyIonsCode ();
  /// Destructor
  ~HeavyIonsCode ();

  /// Initialize simulation from pointer to the @p argc and @p argv parameters
  /// of the main function.
  void Initialize (int* pargc, char*** pargv);

  /// Load EM fields from STW files.
  void LoadFields ();
  /// Reset fields inside of planet to zero
  void ResetFields ();

  /// Execute simulation.
  virtual void Exec ();
  /// Single iteration (called from Code::Exec)
  virtual void Iter ();

  /// Calculate SW acceleration force + gravity
  void CalcForce (const TVector &pos, TVector &force) const;
  /// Calculate output
  void CalcOutput () const;

  /// @brief Move ions by one time step (i.e. _time.Dt() )
  void MoveIons (TSpecie &sp);
  /// @brief Move neutrals by one time step (i.e. _time.Dt() )
  void MoveNeutrals (TSpecie &sp);
  /// @brief Ionize some of the particles.
  void Ionize (TSpecie &sp);

  /// @brief Apply boundary conditions.
  /// @remarks parameters @p pdhit and @p plhit are not reset inside of the
  ///          function but only UPDATED!
  void ApplyBC (TParticleArray &pcles, int &bdhit, int &plhit);

  void CheckPosition (TParticleArray &pcles);

private:
  String _stwname;
  TField _B, _E;
  TSpecieArray _specs;

  SimulTime _time;        ///< simulation time
  SensorManager _sensmng; ///< sensor manager
  int _clean;

  Vector<int,3> _nx;     ///< Number of cells.
  Vector<T,3> _dx, _dxi; ///< Resolution of input (STW) data.
  Vector<T,3> _rx;       ///< Planet relative position.
  Vector<T,3> _lx;       ///< Size of the simulation box (i.e. nx*dx)
  Vector<T,3> _plpos;    ///< Planet position (i.e. nx*dx*rx)
  T _scalef;             ///< Scaling factor for Lorentz force.
  T _radius;             ///< Radius of the planet in hybrid units.
  Vector<T,3> _swaccel;  ///< Solar wind acceleration.
  T _cgrav;              ///< Gravitation constant.
};

/// @}

#endif /* __SAT_HIONS_H__ */
