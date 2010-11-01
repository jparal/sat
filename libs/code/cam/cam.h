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
#include "code/satmisc.h"

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
 * @revmessg{I found out that moment smoothing expects values in the ghost
 *          zones to be the first inner values of the neighbour patch; rather
 *          then shared values on the boundary}
 */
template<class B, class T, int D>
class CAMCode : public Code
{
public:
  typedef Vector<T, D> PosVector;
  typedef Vector<T, 3> VelVector;
  typedef Vector<T, 3> FldVector;

  typedef Field<FldVector, D> VecField;
  typedef Field<T, D> ScaField;

  typedef CamSpecie<T,D> TSpecie;
  typedef typename TSpecie::TParticle TParticle;
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

  /// Initialize from configuration file name @p _cfg
  void Initialize ();

  /// Problem specific initialization called before Initialize()
  /// @remarks @p _cfg is already initialized
  virtual void PreInitialize (const ConfigFile &cfg) {};

  /// Problem specific initialization called after Initialize()
  /// @remarks @p _cfg is already initialized
  virtual void PostInitialize (const ConfigFile &cfg) {};

  /**
   * @brief Finalize and clean CAM simulation.
   * This method is called by destructor so theoretically you don't need to
   * call it explicitly.
   */
  void Finalize ();

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
  bool BcalcAdd (const DomainIterator<D> &itb)
  { return false; }
  bool EcalcAdd (const DomainIterator<D> &ite)
  { return false; }

  T BmaskAdd (const DomainIterator<D> &itb)
  { return (T)1.; }

  T EmaskAdd (const DomainIterator<D> &ite)
  { return (T)1.; }

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
  T ResistAdd (const DomainIterator<D> &iter) const
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
  bool PcleBCAdd (TSpecie *sp, size_t id, TParticle &pcle)
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
  bool PcleBC (TSpecie *sp, size_t id, TParticle &pcle);

  /// Synchronize particles crossing the boundary.
  void PcleSync (TSpecie *sp, ScaField &dn, VecField &U);

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
  /// Called before moving the particles (for DEBUG purpose, I suppose)
  void PreMove () {};
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
  void Inject (TSpecie *sp, ScaField &dn, VecField &U);

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
   * Solve the equation:
   * @f[
   * \frac{\partial \mathbf{B}}{\partial t} = - \nabla \times \mathbf{E}
   * @f]
   * where electric field @f$ \mathbf{E} @f$ is taken from internal
   * variable @p _E and the result is store in @p Ba parameter.
   *
   * @param[in] dt time step
   * @param[in,out] Ba magnetic field to advance
   */
  void CalcB (T dt, const ScaField &psi, VecField &Ba);

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
   * @param[in] b     Magnetic field
   * @param[in] u     Bulk velocity
   * @param[in] dn    Number density
   * @param[in] enpe  Enable electron pressure term?
   */
  void CalcE (const VecField &b, const VecField &u, const ScaField &dn,
              bool enpe = true);

  void CalcPsi (T dt, const VecField &b, ScaField &psi);

  /// Advance Magnetic field by @p dt time using @p _nsub sub-steps.
  void AdvField (T dt);

  /// Advance moment
  void AdvMom ();

  /// Return resistivity at the given position.
  T Resist (const DomainIterator<D> &iter)
  { return _resist + static_cast<B*>(this)->ResistAdd (iter); };

  /// Normalize bulk velocity by the given density.
  void MomNorm (const ScaField &dn, VecField &blk);

  void MomInit ();
  void MomFirst ();
  void MomLast ();

  /// @}

  /// @name Smoothing
  /// @{

  /// Smooth any field
  /// @todo add desription about smoothing algorithm
  template<class T2, int D2>
  void Smooth (Field<T2,D2> &fld);

  /// @}

  /// @name Get/Set
  /// @{

  /// Get simulation time class
  const SimulTime& GetTime () const
  { return _time; }

  /// return configuration file class
  const ConfigFile& GetCfgFile () const
  { return _cfg; }

  /// return number of species
  int GetSpecieSize () const
  { return _specie.Size(); }

  /// return given specie by ID
  const TSpecie* GetSpecie (int i) const
  { return _specie[i]; }

  /// get gamma constant of pressure
  T GetGamma () const
  { return _gamma; }

  /// get electron temperature
  T GetTe () const
  { return _te; }

  /// @}

public:

  // Statistics:
  Timer _timer;      ///< Wall clock timer
  Array<double> _itertime; ///< Time it took to compute an iteration

  SimulTime _time;   ///< simulation time

  int _nsub;         ///< number substep for magnetic field
  T _dnmin;     ///< density threshold when fields are advanced
  T _resist;    ///< global resistivity for code stability
  T _viscos;    ///< global viscosity for code stability

  T _betae;     ///< electron beta
  T _betai;     ///< total ion beta of all species
  T _cs;        ///< sound speed

  /*
   * @p _esmooth and @p _momsmooth parameters have the meaning of number of
   *    iteration between smoothing. That means for esmooth == 1, smoothing is
   *    done every step; for smooth == 2 every two steps and so on. When value
   *    is 0 the smoothing is turned off.
   */
  int _momsmooth;    ///< moment smoothing
  int _esmooth;      ///< electric field smoothing

  T _vmax;                  ///< Square of maximal particle velocity.
  RefArray<TSpecie> _specie; ///< proton species
  PosVector _pmin, _pmax;    ///< minimal/maximal position of particle

  SensorManager _sensmng;   ///< sensor manager
  CartDomDecomp<D> _decomp; ///< domain decomposition

  T _gamma;     ///< Gamma constant in pressure computation
  T _te;        ///<< Electron temperature
  /**
   * Angle of IMF field defined as follows
   * @code
   * Bx0 = cos (phi) * cos (psi);
   * By0 = sin (phi) * cos (psi);
   * Bz0 = sin (psi);
   * @endcode
   */
  T _phi, _psi;
  T _bamp;         ///< Amplitude of solar wind (1 by default)
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
  ScaField _Psi, _Psih; ///< Function for cleaning div B
  ScaField _pe;
  ScaField _dn, _dna, _dnf;
  VecField _U,  _Ua,  _Uf;
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
// Calculate
#include "calcpe.cpp"
#include "calcb.cpp"
#include "calce.cpp"
#include "calcpsi.cpp"
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
#include "pclebc.cpp"
#include "pcleinj.cpp"

/// @}

#endif /* __SAT_CAM_H__ */
