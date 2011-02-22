/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   octreecell.h
 * @brief  Octree cell for distribution function representation.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/01, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_OCTREECELL_H__
#define __SAT_OCTREECELL_H__

#include "math/algebra/vector.h"
#include "base/common/array.h"

/// @addtogroup simul_misc
/// @{

/**
 * @brief Octree cell for distribution function representation.
 *
 * @revision{1.1}
 * @reventry{2011/01, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class OctreeCell
{
  typedef size_t cidx_t;
  typedef Vector<T, D> VPosVector; ///< Position vector in velocity space
public:
  /// Constructor
  OctreeCell ();
  /// Destructor
  ~OctreeCell ();

  void Initialize (Vector<T,D> vmin, Vector<T,D> vmax,
		   int levmin, int levmax, float epsglo, float epsloc,
		   bool balance);

  T DistFunction (const VPosVector &pos) const;

  void DivideCell (cidx_t icell);

private:
  typedef struct
  {
    /// Indexes of the vertices of a cell in a given list of vertices. By
    /// convention, vertices are listed counterclockwise starting with the
    /// lower z level (Richards code: 1-8)
    Vector<cidx_t, MetaPow<2,D>::Is> idx;

    /// Level (Richards code: 9)
    int lev;

    /// Index of the mother cell in the tindex array (Richards code: 10)
    int mom;

    /// Relative index within the parent cell (Richards code: 11)
    int rel;

    /// Index of the first son cell in the _cell array (Richards code: 12)
    /// if -1, there is no daughter but the cell is not a leaf
    ///    -2: the cell must be refined.
    int son;

    /// Indices within the level (Richards code: 13-15)
    Vector<cidx_t, D> ind;

  } OctreeCellInfo;

  typedef struct
  {
    VPosVector pos; ///< Coordinates of distribution function in velocity space
    T          fnc; ///< Distribution function at each vertex
  } DistFncInfo;

  int _nDel;    ///< Number of deleted cells
  T   _volMesh; ///< Volume of the entire mesh

  Array<OctreeCellInfo> _cell; ///< Cell array of octree decomposition
  Array<DistFncInfo>    _dfnc; ///< Vertex array of DF values

  /// @{ Input parameters
  Vector<T,D> _vmin; ///< Minimal allowed velocity of DF
  Vector<T,D> _vmax; ///< Maximal allowed velocity of DF
  int _levelMin;   ///< Minimum (base) level of subdivision in the grid
  int _levelMax;   ///< Maximum level allowed in the grid
  bool _balance;   ///< T or F for a balanced or imbalanced tree
  /// Tolerance in accuracy of integration in a cell compared to that over the
  /// entire mesh
  float _epsglo;
  float _epsloc;  /// Tolerance in accuracy of integration within a mother cell
  /// @}
};

/// @}

#endif /* __SAT_OCTREECELL_H__ */
