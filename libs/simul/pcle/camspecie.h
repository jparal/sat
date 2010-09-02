/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   camspecie.h
 * @brief  Specie description and manipulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @reventry{2009/01, @jparal}
 * @revmessg{Move documentation of Initialize() into DocSpecie.dox file}
 */

#ifndef __SAT_CAMSPECIE_H__
#define __SAT_CAMSPECIE_H__

#include "specie.h"
#include "simul/satfield.h"

/// @addtogroup simul_pcle
/// @{

/**
 * @brief CAM-CL Specie.
 * All particles are stored in the arrays and user can access them through the
 * Specie::Iterator class. This class adds special distribution information on
 * top of the Specie class specific to the CAM-CL code/variable scaling.
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class CamSpecie : public Specie<T,D>
{
public:
  typedef typename Specie<T,D>::TParticle TParticle;
  typedef typename Specie<T,D>::Iterator Iterator;
  typedef typename Specie<T,D>::ConstIterator ConstIterator;

  /// Constructor
  CamSpecie () {
    _mesh.Initialize ();
  };
  /// Destructor
  ~CamSpecie () {};

  /// @name Initialization
  /// @{

  /**
   * @brief Initialize particles information.
   * parameter @e cfg is expected to hold the group of the specie configuration
   * file with parameters. (see @ref cfg_cam "CAM configuration").
   *
   * @sa @ref cfg_cam
   *
   * @param cfg configure entry with specie information
   * @param mesh mesh on which particles reside
   * @param layout layout of the processors
   */
  void Initialize (const ConfigEntry &cfg,
		   const Mesh<D> mesh,
		   const Layout<D> layout);

  /**
   * Generate particles with Maxwell distribution.
   * @todo comment on how the distribution looks like.
   *
   * @remark Probably background magnetic field given by parameter @e b could
   *         be (in the future) defined everywhere as well es bulk
   *         velocity @e u.
   *
   * @param[in] dn particle density scaled to one
   * @param[in] u bulk velocity defined on the mesh vertexes
   * @param[in] b background magnetic field
   */
  void LoadPcles (const Field<T,D> &dn, const Field<Vector<T,3>,D> &u,
		  Vector<T,3> b);

  /// @}

  /// @name Information
  /// @{

  /// get particles Mesh<> object
  const Mesh<D>& GetMesh () const
  { return _mesh; }

  /// Return name (i.e. 'proton', ..)
  const String& GetName () const
  { return _name; }

  /// @brief Plasma beta of the specie.
  /// Is a ratio of the plasma pressure to the magnetic pressure defined as:
  /// @f[ \beta = \frac{p}{B^2/2 \mu_0} @f]
  T Beta () const
  { return _beta; }
  /// Number of macro-particles per cell at initialization
  T InitalPcles () const
  { return _ng; }
  /// Species initial bulk velocity
  const Vector<T,3>& InitalVel () const
  { return _vs; }
  /// ration between perpendicular and parallel temperature
  /// @f$ v_{th,\perp}/v_{th,\parallel} @f$
  T RatioVth () const
  { return _rvth; }
  /// Parallel thermal velocity
  T Vthpar () const
  { return _vthpa; }
  /// Perpendicular thermal velocity
  T Vthper () const
  { return _vthpe; }
  /// relative mass density particle represent with respect to @f$ n_0 @f$
  T RelMassDens () const
  { return _rmds; }
  /// charge/mass ratio in units of electron charge @f$ e @f$ and proton
  /// mass @f$ m_i @f$
  T ChargeMassRatio () const
  { return  _qms; }
  /// Mass represented by single super-particle
  T MassPerPcle () const
  { return  _sm; }
  /// Charge represented by single super-particle
  T ChargePerPcle () const
  { return  _sq; }

  RandomGen<T>* GetRndGen()
  { return &_rnd; }

  BiMaxwellRandGen<T>* GetBiMaxwGen()
  { return &_bimax; }

  /// @}

private:
  /// Mesh
  Mesh<D> _mesh;
  /// Specie name (i.e. proton, ...)
  String _name;
  /// Ion beta of the specie
  T _beta;
  /// Number of macro-particles per cell at initialization
  T _ng;
  /// Species initial bulk velocity
  Vector<T,3> _vs;
  /// vth_perpendicular/vth_parallel
  T _rvth;
  /// Parallel and perpendicular thermal velocity
  T _vthpa, _vthpe;
  /// relative mass density particle represent with respect to n0
  T _rmds;
  /// charge/mass ratio in units of electron charge 'e' and proton mass 'm_i'
  T _qms;
  /// Mass represented by single super-particle
  T _sm;
  /// Charge represented by single super-particle
  T _sq;
  /// random number generators
  RandomGen<T> _rnd;
  BiMaxwellRandGen<T> _bimax;
};

/// @}

#endif /* __SAT_CAMSPECIE_H__ */
