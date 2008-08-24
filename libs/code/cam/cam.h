/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cam.h
 * @brief  Current Advance Method - Cyclic Leapfrog (CAM-CL) hybrid code
 *         implementation.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-28, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CAM_H__
#define __SAT_CAM_H__

#include "satmath.h"
#include "satsimul.h"

/// @addtogroup code_cam
/// @{

/**
 * @brief Current Advance Method - Cyclic Leapfrog (CAM-CL) hybrid code
 *        implementation.
 *
 * @remarks
 * class B (Boundary conditions) is a derived class used to call functions
 * specific to the code itself. This technique is called Curiously Recurring
 * Template Pattern (CRTP)
 * (i.e. http://en.wikipedia.org/wiki/Curiously_Recurring_Template_Pattern).
 * The purpose is to avoid using virtual functions especially in cases where we
 * can expect to call them many times, for example in magnetic field update
 * where for each grid point we need to treat the boundary conditions.
 *
 * @revision{1.0}
 * @reventry{2008/08, @jparal}
 * @revmessg{Initial version}
 * @revmessg{change CalcB function to have only one parameter (the field which
 *          we need to advance); since we call the function only with two same
 *          parameters anyway}
 * @revmessg{490, I found out that moment smoothing expects values in the ghost
 *          zones to be the first inner values of the neighbour patch; rather
 *          then shared values on the boundary}
 */
template<class B, class T, int D>
class CAMCode
{
public:
  typedef Vector<T, D> PosVector;
  typedef Vector<T, 3> VelVector;
  typedef Vector<T, 3> FldVector;

  typedef Field<FldVector, D> VecField;
  typedef Field<T, D> ScaField;

  typedef Particle<T,D> TParticle;
  typedef Specie<T,D> TSpecie;
  typedef typename TSpecie::Iterator TSpecieIterator;
  typedef typename TSpecie::CommandIterator TSpecieCommandIterator;

  /// Constructor
  CAMCode ();
  /// Destructor
  virtual ~CAMCode ();

  /// @name Initialization
  /// @{

  /**
   * @brief Initialize simulation from program parameters.
   *
   * @param argc number of parameters
   * @param argv array of parameters
   */
  void Initialize (int *pargc, char ***pargv);

  /// Initialize from configuration file name (*.sin)
  void Initialize (const char *fname);

  /// @}

  /// @name Problem Specific BC
  /// @{

  /**
   * @brief Problem specific boundary conditions for magnetic field.
   * The function should return @e true if you treated the point of magnetic
   * field yourself and you don't wish the CAM-CL code to update the point
   * given by @p iter Iterator, otherwise return @e false (default).
   *
   * @param iter Iterator to the magnetic field.
   *
   * @return true when point should NOT be computed by code and false otherwise
   */
  bool BcalcAdd (const DomainIterator<D> &iter)
  { return false; }

  /// Extra magnetic field initialization (called at the very beginning)
  /// @note note that magnetic field is already set to _B0 at this point so
  ///       only thing you have to do is change the values of particular
  ///       interest
  void BInitAdd (VecField &b)
  { return; }

  /**
   * @brief Initialize density of the specie on the grid (default 1.0)
   * The value of @p dn should be 1.0 where full amount of particles should be
   * used.
   *
   * @param sp Specie
   * @param dn density
   */
  void DnInitAdd (TSpecie *sp, ScaField &dn)
  { return; }

  /**
   * @brief Initialize bulk velocity for the given specie.
   * Default value is specified in configuration file by parameter @e v0 in the
   * section @e plasma.specie.name.
   *
   * @param sp Specie
   * @param blk  bulk velocity
   */
  void BulkInitAdd (TSpecie *sp, VecField &blk)
  { return; }

  /**
   * @brief Electric field problem specific boundary conditions.
   */
  void EfieldAdd ()
  { return; }

  /**
   * @brief Return the resistivity specific to the problem.
   * Sometimes it is good to specify extra resistivity around the obstacles so
   * the extra wave damping can prevent the wave reflection on the boundaries.
   *
   * @param pos position
   * @return resistivity
   */
  double ResistAdd (const PosVector &pos) const
  { return 0.; }

  /**
   * @brief Treatment of particle boundary conditions specific to your problem.
   * That means you don't have to treat boundary conditions of the simulation
   * box. In the body of the function you can change position as well as
   * velocity. By returning @b true you remove particle from simulation,
   * otherwise return @b false.
   *
   * @param[in]     sp  Specie identification number
   * @param[in]     id  particle ID for Exec() function of Specie
   * @param[in,out] pos Particle position
   * @param[in,out] vel Particle velocity
   *
   * @return return true when you want to remove particle
   */
  bool PcleBCAdd (TSpecie *sp, size_t id, PosVector &pos, VelVector &vel)
  { return false; }

  /// Problem specific moment boundary conditions
  void MomBCAdd (ScaField &dn, VecField &blk)
  { return; }

  /// @}

  /// @name Boundary Conditions (BC)
  /// @{

  /**
   * @brief Treatment of particle boundary conditions.
   * This function basically remove particles (in the case of the open boundary
   * conditions) from the simulation and communicate particles which crossed
   * the boundary. In the body of the function you can change position as well
   * as velocity. By returning @b true you remove particle from simulation,
   * otherwise return @b false.
   *
   * @param[in]     sp  Specie identification number
   * @param[in]     id  particle ID for Exec() function of Specie
   * @param[in,out] pos Particle position
   * @param[in,out] vel Particle velocity
   *
   * @return return true when you want to remove particle
   */
  bool PcleBC (TSpecie *sp, size_t id, PosVector &pos, VelVector &vel);

  /// @brief Moment boundary conditions.
  /// Just add values from neighbour processes and call MomAdd function to take
  /// care of outer boundary of simulation box and the obstacles.
  void MomBC (ScaField &dn, VecField &blk);

  /// Electric field boundary conditions.
  void EfieldBC ();

  /// @}

  /// @name Simulation execution
  /// @{

  /// Main function for simulation execution
  void Exec ();
  /// Make first half step
  void First ();
  /// Make last half step
  void Last ();
  /// Drive simulation from one output to another
  void Hyb ();

  //@}

  /// @name Particles
  /// @{

  /// Move all species and collect moments
  void Move ();

  /// Move single specie and collect density and bulk velocity moments
  void MoveSp (TSpecie *sp, ScaField &dnsa, VecField &Usa,
	       ScaField &dnsb, VecField &Usb);

  /// Inject particles from all boundaries (call InjectAdd which you can
  /// overload to add problem specific particle injection)
  void Inject (TSpecie *sp, ScaField &dn, VecField &U) {}

  /// @}

  /// @name Update/Calculate
  /// @{

  /**
   * @brief Calculate electron pressure from the given density.
   * Using the equation:
   * @f[
   * p_e = T_e n^\gamma
   * @f]
   * where @f$ \gamma = 5/3 @f$ in our case, update variable @p _pe
   *
   * @param dn density
   */
  void CalcPe (const ScaField &dn);

  /**
   * @brief Calculate magnetic field.
   *
   * @param dt time step
   * @param Ba magnetic field to advance
   */
  void CalcB (double dt, VecField &Ba);

  /**
   * @brief Calculate moments density and bulk velocity for the given specie.
   * The method is using standard bilinear weighting and following equations:
   * @f[
   * n_s = \int f_s(x_s, v_s) d^3 v_s
   * @f] @f[
   * (n u)_s = \int v_s f_s(x_s, v_s) d^3 v_s
   * @f]
   *
   * @param[in] sp Specie
   * @param[out] dn density field
   * @param[out] blk bulk velocity
   */
  void CalcMom (TSpecie *sp, ScaField &dn, VecField &blk);

  /**
   * @brief Calculate electric field.
   * The updated values will be stored in the internal variable @p _E by
   * solving equation for electric field:
   * @f[
   * \mathbf{E} = - \frac{\mathbf{J}_i \times \mathbf{B}}{\rho_c} +
   * \frac{(\nabla \times \mathbf{B}) \times \mathbf{B}}{\mu_0 \rho_c} -
   * \frac{\nabla p_e}{\rho_c}
   * @f]
   * where the last term can be disabled by the last parameter @p enpe. This
   * can speed up the computations in the case where we require to compute curl
   * of electric field and the last term would be zero anyway.
   *
   * @param[in] mf    Magnetic field
   * @param[in] blk   Bulk velocity
   * @param[in] dn    Number density
   * @param[in] enpe  Enable electron pressure term?
   */
  void CalcE (const VecField &mf, const VecField &blk, const ScaField &dn,
	      bool enpe = true);

  /// Advance Magnetic field by @p dt time using @p _nsub sub-steps.
  void AdvField (double dt);

  /// Advance moment
  void AdvMom ();

  /// Return resistivity at the given position.
  /// @todo We can add the extra parameter to the configuration file and add
  ///       extra resistivity at the box boundaries when we are dealing with
  ///       open boundary problem.
  double Resist (const PosVector &pos)
  { return _resist + static_cast<B*>(this)->ResistAdd (pos); };

  /// Normalize bulk velocity by the given density.
  void MomNorm (const ScaField &dn, VecField &blk);

  void MomInit ();
  void MomFirst ();
  void MomLast ();

  /// @}

  /// @name Smoothing
  /// @{

  // Smooth scalar field
  //  void MomSmooth (ScaField &f) {}
  // Smooth vector field
  // void MomSmooth (VecField &f) {}
  // Smooth electric field  field
  //  void EfieldSmooth () {}

  /// Smooth any field
  /// @todo add desription about smoothing algorithm
  template<class T2, int D2>
  void Smooth (Field<T2,D2> &fld);

  /// @}

protected:
  ConfigFile _cfg;   ///< parsed configuration file
  satversion_t _ver; ///< version of configuration file

  SimulTime _time;   ///< simulation time

  int _nsub;         ///< number substep for magnetic field
  double _dnmin;     ///< density threshold when fields are advanced
  double _resist;    ///< global resistivity for code stability

  double _betae;     ///< electron beta
  double _betai;     ///< total ion beta

  int _momsmooth;    ///< moment smoothing
  int _esmooth;      ///< electric field smoothing

  RefArray<Specie<T,D> > _specie; ///< proton species
  PosVector _pmin, _pmax;         ///< minimal/maximal position of particle

  SensorManager _sensmng;   ///< sensor manager
  CartDomDecomp<D> _decomp; ///< domain decomposition

  double _gamma;     ///< Gamma constant in pressure computation
  double _te;        ///<< Electron temperature
  /**
   * Angle of IMF field defined as follows
   * @code
   * Bx0 = cos (phi) * cos (psi);
   * By0 = sin (phi) * cos (psi);
   * Bz0 = sin (psi);
   * @endcode
   */
  T _phi, _psi;
  Vector<T,3> _v0; ///< bulk velocity of entire plasma
  Vector<T,3> _B0; ///< Initial/background magnetic field
  Vector<T,3> _E0; ///< Initial electric field

  Mesh<D> _meshe;
  Mesh<D> _meshb;
  Mesh<D> _meshu;
  Mesh<D> _meshp;

  Layout<D> _layoe;
  Layout<D> _layob;
  Layout<D> _layou;
  Layout<D> _layop;

  VecField _B;
  VecField _Bh;
  VecField _E;
  ScaField _pe;
  ScaField _dn, _dna, _dnf;
  VecField _U,  _Ua,  _Uf;

  String _exename; ///< name of file executable
  String _runname;
  String _logname;
  String _cfgname;
};

// Execute
#include "init.cpp"
#include "exec.cpp"
#include "hyb.cpp"
#include "first.cpp"
#include "last.cpp"
// Particles
#include "movesp.cpp"
#include "move.cpp"
#include "pclebc.cpp"
// Calculate
#include "calcpe.cpp"
#include "calcb.cpp"
#include "calce.cpp"
#include "calcmom.cpp"
#include "advmom.cpp"
#include "advfld.cpp"
#include "mominit.cpp"
#include "momnorm.cpp"
#include "momfirst.cpp"
#include "momlast.cpp"
#include "smooth.cpp"
// Boundary conditions
#include "efldbc.cpp"
#include "mombc.cpp"

/// @}

#endif /* __SAT_CAM_H__ */
