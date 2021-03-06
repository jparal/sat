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
 * @brief Heavy ions Monte-Carlo simulation of Mercury.
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
  typedef typename TSpecie::TWeightField TWeightField;

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

  /// Calculate solar wind + gravity acceleration
  void CalcAccel (const TVector &pos, TVector &force) const;
  /// Calculate output
  void CalcOutput () const;

  /// @brief Move ions by one time step @p dt
  void MoveIons (TParticleArray &pcles, T qms, T dt);
  /// @brief Move neutrals by one time step.
  void MoveNeutrals (TParticleArray &pcles, T dt);

  /**
   * @brief Ionize some of the particles.
   *
   * @param[in,out] ions Ions.
   * @param[in,out] neut Neutrals.
   * @param[in,out] weight Weight.
   * @param[out] ionized Number of particles ionized.
   */
  void Ionize (TParticleArray &ions, TParticleArray &neut,
	       TWeightField &weight, int &ionized);

  /// @brief Apply boundary conditions.
  /// @remarks parameters @p pdhit and @p plhit are not reset inside of the
  ///          function but only UPDATED!
  void ApplyBC (TParticleArray &pcles, int &bdhit, int &plhit);

  void CheckPosition (TParticleArray &pcles);

  /// @brief Clean particles which has weight less then 0.
  void CleanPcles (TParticleArray &pcles, int &cleaned);

private:
  String _stwname;
  int _nsub; ///< ion substeps
  TField _B, _E;
  TSpecieArray _specs;

  SimulTime _time;        ///< simulation time
  SIHybridUnitsConvert<T> _si2hyb; //< SI to hybrid units conversion
  SensorManager _sensmng; ///< sensor manager
  int _clean;

  Vector<int,3> _nx;     ///< Number of cells.
  Vector<T,3> _dx, _dxi; ///< Resolution of input (STW) data.
  Vector<T,3> _lx;       ///< Size of the simulation box (i.e. nx*dx)
  Vector<T,3> _rx;       ///< Planet relative position.
  Vector<T,3> _plpos;    ///< Planet position (i.e. nx*dx*rx)
  T _scalef;             ///< Scaling factor for Lorentz force.
  T _radius, _radius2;   ///< Radius of the planet in hybrid units.
  T _swaccel;            ///< Solar wind acceleration.
  T _cgrav;              ///< Gravitation constant.

  /**
   * @brief Ionization constant.
   * Ionization constant is defined as follows:
   * @f[ c_i = \sum_p \frac{1}{\tau_p} @f]
   * where @p p is a ionization process and @f$ \tau @f$ is a lifetime of the
   * process @p p.
   */
  T _cionize;
  T _distau; ///< Distance from the Sun [AU]
};

/// @}

#endif /* __SAT_HIONS_H__ */
