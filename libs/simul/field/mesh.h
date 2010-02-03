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

/// @addtogroup simul_field
/// @{

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

  void Initialize (const Vector<int,D>& ncell,
		   const Vector<double,D>& resol,
		   Centring center);

  // Length .. , 
  int GetCells (int i) const
  { return _ncell[i]; }

  const Vector<int,D>& Cells () const
  { return _ncell; }

  const Vector<double,D>& Resol () const
  { return _resol; }

  double GetResol (int i) const
  { return _resol[i]; }

  double GetResolInv (int i) const
  { return _finvresol[i]; }

  double GetResolInvQ (int i) const
  { return _qinvresol[i]; }

  double GetResolInvH (int i) const
  { return _hinvresol[i]; }

  Vector<int,D> GetResolInv () const
  { return _finvresol; }

  Vector<int,D> GetResolInvQ () const
  { return _qinvresol; }

  Vector<int,D> GetResolInvH () const
  { return _hinvresol; }

  Centring Center () const
  { return _center; }


  Vector<double,D> Size ()
  {
    Vector<double,D> size;
    for (int i=0;i<D;++i) size[i] = _resol[i]*_ncell[i];
    return size;
  }
  Vector<double,D>& Resol ()  { return _resol; }
  Vector<int,D>& Cells ()  { return _ncell; }
  void Initialize (const ConfigEntry &cfg);
  Centring& Center () { return _center; }

private:
  void UpdateResol ();

  /// Dimensions of the data
  Vector<int,D> _ncell;
  /// Resolution between the grid points.
  Vector<double,D> _resol;
  Vector<double,D> _finvresol;
  Vector<double,D> _qinvresol;
  Vector<double,D> _hinvresol;
  Centring _center;   /// Placement of the values on the rectangular mesh
};

/// @}

#endif /* __SAT_MESH_H__ */
