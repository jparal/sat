/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   updateshare.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/08, @jparal}
 * @revmessg{490, rename from addghosts.cpp}
 */

template<class T, int D>
void Field<T,D>::UpdateSharedDir (int dim, bool right)
{
  SAT_DBG_ASSERT (_havegrid);

  const CartDomDecomp<D> &decomp = _layout.GetDecomp ();

  // No 'share' layer is present
  if (_layout.GetShare (dim) < 1) return;
  // Left open boundary not treated
  if (decomp.IsLeftBnd (dim) && !right && _layout.IsOpen (dim)) return;
  // Right open boundary not treated
  if (decomp.IsRightBnd (dim) && right && _layout.IsOpen (dim)) return;

  Domain<D> dcache;
  Domain<D> dshare;
  GetDomainAll (dcache);
  GetDomainAll (dshare);

  int share = _layout.GetShare (dim);
  int ghost = _layout.GetGhost (dim);

  if (right)
  {
    dcache[dim].Lo () = dcache[dim].Hi () - ghost + 1;
    dcache[dim].Hi () = dcache[dim].Lo () + share - 1;

    dshare[dim].Lo () = dcache[dim].Lo () - share;
    dshare[dim].Hi () = dcache[dim].Hi () - share;
  }
  else
  {
    dcache[dim].Hi () = dcache[dim].Lo () + ghost - 1;
    dcache[dim].Lo () = dcache[dim].Hi () - share + 1;

    dshare[dim].Hi () = dcache[dim].Hi () + share;
    dshare[dim].Lo () = dcache[dim].Lo () + share;
  }

  DomainIterator<D> ishare (dshare);
  DomainIterator<D> icache (dcache);
  while (ishare.HasNext ())
  {
    // @TODO switch base on the operation ... for now only addition is
    //       supported
    (*this)(ishare.GetLoc ()) += (*this)(icache.GetLoc ());

    ishare.Next ();
    icache.Next ();
  }
}

template<class T, int D>
void Field<T,D>::UpdateShared ()
{
  for (int i=0; i<D; ++i)
  {
    UpdateSharedDir (i, true);
    UpdateSharedDir (i, false);
  }
}
