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

/// @addtogroup simul_pcle
/// @{

/**
 * Specie description and manipulation.
 * All particles are stored in the arrays and user can access them through the
 * Specie::Iterator class.
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/12, @jparal}
 * @revmessg{Split Specie class into base class and derived CamSpecie for
 *          CAM-CL specific functionality (i.e. LoadPcles; Initialize)}
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
  { _layout.Initialize (); }

  /// Destructor
  ~Specie () {};

  /// @name Initialization
  /// @{

  /// Initialize
  void Initialize (Layout<D> layout)
  { _layout = layout; }

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
    size_t pos;
    SAT_OMP_CRITICAL // Required by movesp parallel loop
    pos =_cmdqueue.InsertSortedUnique (PcleCommandInfo (ipcle, cmd));
    // @TODO we could use third parameter of InsertSortedUnique to update cmd
    //       parameter only in the case when command already exists (faster)
    _cmdqueue[pos].cmd |= cmd;
  }

  size_t Push (TParticle &pcle)
  { return _pcles.Push(pcle); }

  /// return the number of particles on the current processor
  size_t GetSize () const
  { return _pcles.GetSize (); }

  /// return the total number of particles on all current processor together
  size_t GetTotalSize () const;

  /// get particle by ID
  TParticle& Get (size_t id)
  { return _pcles.Get (id); }

  /// get particle by ID
  const TParticle& Get (size_t id) const
  { return _pcles.Get (id); }

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

  /// @name Debug
  /// @{

  // Debugging function checking the consistency of command queue
  // opt = 0 .. check whether all particles id < maximal one
  // opt = 1 .. check info[i].pid < info[i+1].pid for i=0..N
  void Check (int opt);

  /// @}

  void Save (FILE *file)
  { _pcles.Save (file); }

  void Load (FILE *file)
  { _pcles.Load (file); }

private:

  Array<TParticle> _pcles;
  Array<PcleCommandInfo> _cmdqueue;

  Layout<D> _layout;

#ifdef HAVE_MPI
  int Send (int dim, bool left);
  int Recv (int dim, bool left);
#endif
};

/// @}

#endif /* __SAT_SPECIE_H__ */
