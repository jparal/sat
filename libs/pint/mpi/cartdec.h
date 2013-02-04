/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cartdec.h
 * @brief  Domain splitting routine
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CARTDEC_H__
#define __SAT_CARTDEC_H__

#include "satbase.h"
#include "satmath.h"
#include "wrap.h"

/// @addtogroup pint_mpi
/// @{

/**
 * @brief Cartesian domain decomposition splitting routine
 *
 * @revision{1.0}
 * @reventry{2008-06-03, @jparal}
 * @revmessg{Initial version}
 */
template<int D>
class CartDomDecomp
{
public:
  /// Constructor
  CartDomDecomp ();

  void Initialize ();

  /**
   * Initialize Cartesian domain decomposition.
   *
   * @param[in] ratio ration of decomposition
   * @param[in] comm Communicator of decomposition
   * @param[in] iproc Current processor, if less then 1 then Mpi::Rank is used
   * @param[in] nproc Number of processors to decompose. When nproc is less
   *       then 1 then Mpi::Nodes () is used.
   */
  void Initialize (const Vector<int,D> &ratio, Mpi::Comm comm,
		   int iproc = -1, int nproc = -1);

  void Decompose (Vector<int,D> &vec);

  Mpi::Comm GetComm () const
  { return _comm; }
  int GetIProc () const
  { return _iproc; }
  int GetNProc () const
  { return _nproc; }

  int GetPosition (int idim) const
  { return GetPosition (idim, _iproc); }

  Vector<int,D> Position () const;

  int GetLeft (int idim) const
  { return GetLeft (idim, _iproc); }

  int GetRight (int idim) const
  { return GetRight (idim, _iproc); }

  int GetSize (int idim) const
  { return _npe[idim]; }

  const Vector<int,D>&  Size () const
  { return _npe; }

  int GetPosition (int idim, int iproc) const;
  int GetLeft (int idim, int iproc) const;
  int GetRight (int idim, int iproc) const;

  bool IsBnd (int dim) const
  { return (IsLeftBnd (dim, _iproc) || IsRightBnd (dim, _iproc)); }
  bool IsLeftBnd (int dim) const
  { return IsLeftBnd (dim, _iproc); }
  bool IsRightBnd (int dim) const
  { return IsRightBnd (dim, _iproc); }

  bool IsBnd (int dim, int iproc) const
  { return (IsLeftBnd (dim, iproc) || IsRightBnd (dim, iproc)); }
  bool IsLeftBnd (int dim, int iproc) const
  { return (_ipe[iproc][dim] == 0); }
  bool IsRightBnd (int dim, int iproc) const
  { return (_ipe[iproc][dim] == _npe[dim]-1); }

  static void SplitProcessors (Vector<int,D>& ratio, int nproc);

private:
  // Expects that _npe is already set.
  void Init (int iproc);

  int _iproc, _nproc;
  Mpi::Comm _comm;

  typedef Array<Vector<int,D> > LocArray;

  Vector<int,D> _npe; ///< Number of decompositions
  LocArray _ipe; ///< Position index in hypercube
  LocArray _lpe; ///< Index of domain on the left
  LocArray _rpe; ///< Index of domain on the right
};

/// @}

#endif /* __SAT_CARTDEC_H__ */
