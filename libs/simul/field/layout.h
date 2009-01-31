/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   layout.h
 * @brief  Spatial distribution of Field over several processors
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_LAYOUT_H__
#define __SAT_LAYOUT_H__

#include "pint/mpi/cartdec.h"

/** @addtogroup simul_field
 *  @{
 */

/**
 * @brief Spatial distribution of Field over several processors.
 * This class describe how the meshes are connected across the processes, using
 * terms @e share and @e ghost layers. Share layer is a layer of the values
 * which reside on both neighbouring patches and is updated using one of the
 * numerical operation (add, sub, ...). On the other hand ghost zones (values
 * sourounding computation cells) are just a copy of the values from the
 * neighbour patch taken from first inner values after the shared values.
 * @anchor fig_layout
 * @verbatim
 * CPU:       <-------CPU0-----    ||   -----CPU1------>
 *                                 ||
 * OPERATION:      share operation || (add, ..)
 *                    +-------------------------+   copy from
 *        copy from   |       +-----------------|-------+
 *            +-------|-------|---------+       |       |
 *            |       v       v    ||   v       v       |
 * NODES:  ===*=======*       *    ||   *       *=======*====
 * TYPE:           (SHARE) (GHOST) || (GHOST) (SHARE)
 * @endverbatim
 *
 * @sa Field::Sync
 * @remarks Implementation require that @#ghost >= @#share so we can use ghost
 *          zone as a cache for communication of shared zone between executing
 *          share operation. This way we are able to communicate shared values
 *          in both direction before operation take place.
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/08, @jparal}
 * @revmessg{490, add concept of share and ghost layers so we can support
 *          larger variety of meshes}
 */
template<int D>
class Layout
{
public:
  /// Constructor
  Layout ()
  { Initialize (); }

  /// copy constructor
  Layout (const Layout<D> &layout);

  /// Destructor
  //~Layout ();

  /// Basic initialization
  void Initialize ();

  /// Initialize
  void Initialize (const Vector<int,D> &ghost,
		   const Vector<int,D> &share,
		   const Vector<bool,D> &open,
		   const CartDomDecomp<D> &decomp);

  /// return @e true if boundary in the dimension @p i are open or @e false
  /// when boundary are periodic
  bool IsOpen (int i) const
  { return _open[i]; }

  const Vector<bool,D> GetOpen () const
  { return _open; }

  /// return domain decomposition of the layout
  const CartDomDecomp<D>& GetDecomp () const
  { return _decomp; }

  /// return vector containing ghost zones in each dimension
  const Vector<int,D>& Ghost () const
  { return _ghost; }

  /// return number of ghost cells in the dimension @p i
  int GetGhost (int i) const
  { return _ghost[i]; }

  /// return vector containing share zones in each dimension
  const Vector<int,D>& Share () const
  { return _share; }

  /// return number of shared cells in the dimension @p i
  int GetShare (int i) const
  { return _share[i]; }

private:
  Vector<int,D> _ghost;
  Vector<int,D> _share;
  Vector<bool,D> _open;
  CartDomDecomp<D> _decomp;
};

/** @} */

#endif /* __SAT_LAYOUT_H__ */
