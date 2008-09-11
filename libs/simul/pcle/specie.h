/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   specie.h
 * @brief  Specie description and manipulation
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_SPECIE_H__
#define __SAT_SPECIE_H__

#include "simul/satfield.h"
#include "pcle.h"
#include "cmdpcle.h"

/** @addtogroup simul_pcle
 *  @{
 */

/**
 * Specie description and manipulation.
 * All particles are stored in the arrays and user can access them through the
 * Specie::Iterator class.
 *
 * @remarks Later we can simply separate code specific to CAM code (in derived
 *          class) and a generic one (in base class). The base class would be
 *          then responsible for loading desired distribution and derived class
 *          would just provide parameters.
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class Specie : public RefCount
{
public:
  typedef Particle<T,D> TParticle;
  typedef typename Array<Particle<T,D> >::Iterator Iterator;
  typedef typename Array<Particle<T,D> >::ConstIterator ConstIterator;

  /// Constructor
  Specie ()
  {
    _mesh.Initialize ();
    _layout.Initialize ();
  };
  /// Destructor
  ~Specie () {};

  /// @name Initialization
  /// @{

  /**
   * @brief Initialize particles information.
   * For configure file:
   * @anchor cfg_specie
   * @code
   * plasma:
   * {
   *   specie:
   *   {
   *     proton:
   *     {
   *       pcles = 100;
   *       beta = 0.5;
   *       rvth = 0.5;
   *       rmds = 1.;
   *       qms = 1.;
   *       v0 = [3.,0.,0.];
   *     };
   *   };
   * };
   * @endcode
   * parameter @e cfg is expected to hold the group @e proton, for the example
   * above.
   * @sa @ref cfg_cam
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

  /// @name Command Queue
  /// @{

  /// Iterator for specific command
  class CommandIterator
  {
  public:
    /// Constructor
    CommandIterator (pclecmd_t cmd, Array<PcleCommandInfo> &array)
      : _idx(0), _cmd(cmd), _array(array)
    { HasNext (); }

    /// Is there more elements?
    /// @remarks This function has to be called first before any Next() calling
    bool HasNext ()
    {
      while (_idx < _array.GetSize ())
      {
	if (_array[_idx].cmd & _cmd)
	  return true;
	else
	  ++_idx;
      }

      return false;
    }

    /// Next command information
    PcleCommandInfo& Next (bool remove)
    {
      HasNext ();

      if (remove)
	_array[_idx].cmd &= ~_cmd;

      return _array.Get (_idx);
    }

    /// Remove current item in command queue on which Iterator is pointing.
    void Remove ()
    { _array.DeleteIndexFast (_idx); }

    /// Reset the iterator
    void Reset ()
    { _idx = 0; }

  private:
    size_t _idx;
    pclecmd_t _cmd;
    Array<PcleCommandInfo> &_array;
  };

  /// Return iterator for the specific command issued
  CommandIterator GetCommandIterator (pclecmd_t cmd)
  { return CommandIterator (cmd, _cmdqueue); }

  /// Return iterator over all particles
  Iterator GetIterator ()
  { return _pcles.GetIterator (); }

  /// Return constant iterator over all particles
  ConstIterator GetIterator () const
  { return _pcles.GetIterator (); }

  /**
   * @brief Synchronize all particles.
   * That means, communicate all particles which crossed the boundary across
   * the domain.  The new coming particles will be marked by command
   * PCLE_CMD_ARRIVED and you can access them by getting the iterator by
   * calling:
   * @code
   * CommandIterator iter = GetCommandIterator (PCLE_CMD_ARRIVED);
   * @endcode
   *
   * @param[out] send [optional] number of particles send to other processors
   * @param[out] recv [optional] number of particles arrived
   * @return whether we processed any particle during the synchronization
   */
  bool Sync (int *send = NULL, int *recv = NULL);

  /// Remove particles scheduled for removal and return its number
  int Clean (int *clean = NULL);

  /**
   * Execute single command on the particle
   *
   * @param ipcle id of the particle
   * @param cmd command to be executed
   */
  void Exec (size_t ipcle, pclecmd_t cmd)
  {
    size_t pos =_cmdqueue.InsertSortedUnique (PcleCommandInfo (ipcle, cmd));
    // @TODO we could use third parameter of InsertSortedUnique to update cmd
    //       parameter only in the case when command already exists (faster)
    _cmdqueue[pos].cmd |= cmd;
  }

  /// return the number of particles on the current processor
  size_t GetSize ()
  { return _pcles.GetSize (); }

  /// return the total number of particles on all current processor together
  size_t GetTotalSize ();

  /// get particle by ID
  TParticle& Get (size_t id)
  { return _pcles.Get (id); }

  /// get particle by ID
  const TParticle& Get (size_t id) const
  { return _pcles.Get (id); }

  /// get particles Mesh<> object
  const Mesh<D>& GetMesh () const
  { return _mesh; }

  /// get particles Layout<> object
  const Layout<D>& GetLayout () const
  { return _layout; }

  /**
   * @brief Schedule remove of the particle.
   * Execute remove command on the particle which is the same as calling:
   * @code
   * Exec (ipcle, PCLE_CMD_REMOVE)
   * @endcode
   *
   * @note Note that this calling doesn't remove the particle physically yet.
   *       To do that, you have to call ExecAll method.
   *
   * @param ipcle ID of the particle
   */
  //  void Remove (size_t ipcle);

  /// @}

  /// @name Information
  /// @{

  /// Return name (i.e. 'proton', ..)
  const String& GetName () const
  { return _name; }

  /// @brief Plasma beta of the specie.
  /// Is a ratio of the plasma pressure to the magnetic pressure defined as:
  /// @f[ \beta = \frac{p}{B^2/2 \mu_0} @f]
  float Beta () const
  { return _beta; }
  /// Number of macro-particles per cell at initialization
  float InitalPcles () const
  { return _ng; }
  /// Species initial bulk velocity
  const Vector<float,3>& InitalVel () const
  { return _vs; }
  /// ration between perpendicular and parallel temperature
  /// @f$ v_{th,\perp}/v_{th,\parallel} @f$
  float RatioVth () const
  { return _rvth; }
  /// Parallel thermal velocity
  float Vthpar () const
  { return _vthpa; }
  /// Perpendicular thermal velocity
  float Vthper () const
  { return _vthpe; }
  /// relative mass density particle represent with respect to @f$ n_0 @f$
  float RelMassDens () const
  { return _rmds; }
  /// charge/mass ratio in units of electron charge @f$ e @f$ and proton
  /// mass @f$ m_i @f$
  float ChargeMassRatio () const
  { return  _qms; }
  /// Mass represented by single super-particle
  float MassPerPcle () const
  { return  _sm; }
  /// Charge represented by single super-particle
  float ChargePerPcle () const
  { return  _sq; }

  /// @}

  /// @name Debug
  /// @{

  // Debugging function checking the consistency of command queue
  // opt = 0 .. check whether all particles id < maximal one
  // opt = 1 .. check info[i].pid < info[i+1].pid for i=0..N
  void Check (int opt);

  /// @}

private:
  String _name;

  /// Ion beta of the specie
  float _beta;
  /// Number of macro-particles per cell at initialization
  float _ng;
  /// Species initial bulk velocity
  Vector<float,3> _vs;
  /// vth_perpendicular/vth_parallel
  float _rvth;
  /// Parallel and perpendicular thermal velocity
  float _vthpa, _vthpe;
  /// relative mass density particle represent with respect to n0
  float _rmds;
  /// charge/mass ratio in units of electron charge 'e' and proton mass 'm_i'
  float _qms;
  /// Mass represented by single super-particle
  float _sm;
  /// Charge represented by single super-particle
  float _sq;

  RandomGen<T> _rnd;

  Array<TParticle> _pcles;
  Array<PcleCommandInfo> _cmdqueue;

  Mesh<D> _mesh;
  Layout<D> _layout;

  int Send (int dim, bool left);
  int Recv (int dim, bool left);
};

/** @} */

#endif /* __SAT_SPECIE_H__ */
