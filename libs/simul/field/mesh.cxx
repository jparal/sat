/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   mesh.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "mesh.h"

template<int D>
void Mesh<D>::Initialize ()
{
  _dim = 0;
  _spacing = 1.;
  _origin = 0.;
  UpdateSpacing ();
}

template<int D>
void Mesh<D>::Initialize (const Vector<int,D>& dim,
			  const Vector<double,D>& spacing,
			  const Vector<double,D>& origin,
			  Centring center)
{
  _dim = dim;
  _spacing = spacing;
  _center = center;
  _origin = origin;
  UpdateSpacing ();
}

template<int D>
void Mesh<D>::Initialize (const ConfigEntry &cfg)
{
  const ConfigEntry &cells = cfg ["cells"];
  const ConfigEntry &resol = cfg ["resol"];

  for (int i=0; i<D; ++i)
  {
    _dim[i] = cells[i];
    _spacing[i] = resol[i];
    _origin[i] = 0.;
  }
  _center = Node;
  UpdateSpacing ();
}

template<int D>
void Mesh<D>::UpdateSpacing ()
{
  for (int i=0; i<D; i++)
  {
    _finvspacing[i] = 1.00 / _spacing[i];
    _hinvspacing[i] = 0.50 / _spacing[i];
    _qinvspacing[i] = 0.25 / _spacing[i];
  }
}

template class Mesh<1>;
template class Mesh<2>;
template class Mesh<3>;
template class Mesh<4>;
template class Mesh<5>;
template class Mesh<6>;
