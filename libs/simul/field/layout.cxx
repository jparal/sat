/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   layout.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "layout.h"

template<int D>
Layout<D>::Layout (const Layout<D> &layout)
{
  _ghost = layout._ghost;
  _share = layout._share;
  _open = layout._open;
  _decomp = layout._decomp;
}

template<int D>
void Layout<D>::Initialize ()
{
  _ghost = 0;
  _share = 0;
  _open = false;
  _decomp.Initialize ();
}

template<int D>
void Layout<D>::Initialize (const Vector<int,D> &ghost,
			    const Vector<int,D> &share,
			    const Vector<bool,D> &open,
			    const CartDomDecomp<D> &decomp)
{
  _ghost = ghost;
  _share = share;
  _open = open;
  _decomp = decomp;

  for (int i=0; i<D; ++i)
    SAT_ASSERT (_ghost[i] >= _share[i]);
}

template class Layout<1>;
template class Layout<2>;
template class Layout<3>;
