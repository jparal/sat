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
  _ncell = 0;
  _resol = 1.;
  _origin = 0.;
  UpdateResol ();
}

template<int D>
void Mesh<D>::Initialize (const Vector<int,D>& ncell,
			  const Vector<double,D>& resol,
			  const Vector<double,D>& origin,
			  Centring center)
{
  _ncell = ncell;
  _resol = resol;
  _center = center;
  _origin = origin;
  UpdateResol ();
}

template<int D>
void Mesh<D>::Initialize (const ConfigEntry &cfg)
{
  const ConfigEntry &cells = cfg ["cells"];
  const ConfigEntry &resol = cfg ["resol"];

  for (int i=0; i<D; ++i)
  {
    _ncell[i] = cells[i];
    _resol[i] = resol[i];
    _origin[i] = 0.;
  }
  _center = Node;
  UpdateResol ();
}

template<int D>
void Mesh<D>::UpdateResol ()
{
  for (int i=0; i<D; i++)
  {
    _finvresol[i] = 1.00 / _resol[i];
    _hinvresol[i] = 0.50 / _resol[i];
    _qinvresol[i] = 0.25 / _resol[i];
  }
}

template class Mesh<1>;
template class Mesh<2>;
template class Mesh<3>;
template class Mesh<4>;
template class Mesh<5>;
template class Mesh<6>;
