/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mesh.h
 * @brief  Cartesian uniform mesh description (i.e. dimnesions, spacing)
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_MESH_H__
#define __SAT_MESH_H__

#include "satmath.h"
#include "base/cfgfile/cfgfile.h"

/** @addtogroup simul_field
 *  @{
 */

/// Centring of the variables on the mesh
enum Centring
{
  Cell,
  Node
};

/**
 * @brief Cartesian uniform mesh description (i.e. dimnesions, spacing)
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/2H, @jparal}
 * @revmessg{490, changed the order of parameters in Initialize; this makes
 *          more sense}
 */
template<int D>
class Mesh
{
public:

  /// Constructor
  Mesh ()
  { Initialize (); }

  void Initialize ();

  void Initialize (const Vector<int,D>& dim,
		   const Vector<double,D>& spacing,
		   const Vector<double,D>& origin,
		   Centring center);

  void Initialize (const ConfigEntry &cfg);

  int GetDim (int i) const
  { return _dim[i]; }

  double GetSpacing (int i) const
  { return _spacing[i]; }

  double GetSpacingInv (int i) const
  { return _finvspacing[i]; }

  double GetSpacingInvQ (int i) const
  { return _qinvspacing[i]; }

  double GetSpacingInvH (int i) const
  { return _hinvspacing[i]; }

  Vector<int,D> GetSpacingInv () const
  { return _finvspacing; }

  Vector<int,D> GetSpacingInvQ () const
  { return _qinvspacing; }

  Vector<int,D> GetSpacingInvH () const
  { return _hinvspacing; }

  double GetOrigin (int i) const
  { return _origin[i]; }

  const Vector<int,D>& Dim () const
  { return _dim; }

  const Vector<double,D>& Spacing () const
  { return _spacing; }

  const Vector<double,D>& Origin () const
  { return _origin; }

  Centring Center () const
  { return _center; }

  Vector<int,D>& Dim ()
  { return _dim; }

  Vector<double,D>& Spacing ()
  { return _spacing; }

  Vector<double,D>& Origin ()
  { return _origin; }

  Centring& Center ()
  { return _center; }

private:
  void UpdateSpacing ();

  /// Dimensions of the data
  Vector<int,D> _dim;
  /// Spacing between the grid points.
  Vector<double,D> _spacing;
  Vector<double,D> _finvspacing;
  Vector<double,D> _qinvspacing;
  Vector<double,D> _hinvspacing;
  /// Local origin (can change when Distribution class is provided)
  Vector<double,D> _origin;
  /// Placement of the values
  Centring _center;
};

/** @} */

#endif /* __SAT_MESH_H__ */
