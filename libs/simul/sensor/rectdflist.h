/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   rectdflist.h
 * @brief  List of all distribution functions
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RECTDFLIST_H__
#define __SAT_RECTDFLIST_H__

#include "rectdfcell.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief List of all distribution functions
 *
 * @revision{1.1}
 * @reventry{2011/02, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int DP, int DV>
class DistFunctionList
{
public:
  /// Constructor
  //  DistFunctionList ();
  /// Destructor
  //  ~DistFunctionList ();

  void Initialize (const Vector<int,DV> &ncell,
		   const Vector<T,DV> &vmin, const Vector<T,DV> &vmax);

  /// Add distribution for the cell ic. You can specify nc as a total number of
  /// cells per single process. This number will be used tag generation during
  /// saving process.
  void AddDF (const Vector<int,DP> &ic, const Vector<int,DP> &nc = 0);

  /// Return distribution functions index if DF exists otherwise -1.  If index
  /// is greater or equal than 0 you can go ahead and call Update function.
  /// This way you can perform post-processing of the velocity only if you are
  /// going to update any distribution function.
  int GetDistFncIndex (const Vector<T,DP> &pos) const;

  /// Update distribution function with index idx. Returns true on success
  /// otherwise false.  You can obtain idx argument from calling
  /// GetDistFncIndex function.
  bool Update (int idx, const Vector<T,DV> &vel);

  bool Update (const Vector<T,DP> &pos, const Vector<T,DV> &vel);

  void Write (HDF5File &file, const char *tag) const;

  int GetNumDFs () const
  { return _dfs.GetSize (); }

private:

  template<class TDF, int DPDF, int DVDF>
  struct DistFuncInfo : public RefCount
  {
    RectDistFunction<TDF,DVDF> df; ///< Distribution function storage
    Vector<int,DPDF> ic;           ///< Local cell index
    Vector<int,DPDF> nc;           ///< Number of cells per process
  };
  typedef DistFuncInfo<T,DP,DV> TDistFuncInfo;

  RefArray< DistFuncInfo<T,DP,DV> > _dfs;
  Vector<T,DV> _vmin, _vmax;
  Vector<int,DV> _ncell;
};

/// @}

#endif /* __SAT_RECTDFLIST_H__ */
