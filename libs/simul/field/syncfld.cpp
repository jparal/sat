/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   syncfld.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "simul/satmisc.h"

#define SYNC_RIGHT true
#define SYNC_LEFT false

template<class T, int D>
void Field<T,D>::Send (int dim, bool right, bool shared)
{
  const CartDomDecomp<D> &dec = _layout.GetDecomp ();

  bool isbnd = right ? dec.IsRightBnd (dim) : dec.IsLeftBnd (dim);
  if (isbnd && _layout.IsOpen (dim)) return;

  int tag = 0; ///@todo generate unique tag
  int prc = right ? dec.GetRight (dim) : dec.GetLeft (dim);
  MpiOStream<T> os (prc, tag, dec.GetComm ());

  Domain<D> dom;
  GetDomainAll (dom);

  int share = _layout.GetShare (dim);
  int ghost = _layout.GetGhost (dim);

  if (shared)
  {
    // no shared layer present
    if (share < 1) return;

    if (right)
    {
      dom[dim].Lo () = dom[dim].Hi () - ghost - share + 1;
      dom[dim].Hi () = dom[dim].Lo () + share - 1;
    }
    else // if (!right)
    {
      dom[dim].Hi () = dom[dim].Lo () + ghost + share - 1;
      dom[dim].Lo () = dom[dim].Hi () - share + 1;
    }
  }
  else // if (!shared)
  {
    if (right)
    {
      dom[dim].Hi () = dom[dim].Hi () - ghost - share;
      dom[dim].Lo () = dom[dim].Hi () - ghost + 1;
    }
    else // if (!right)
    {
      dom[dim].Lo () = dom[dim].Lo () + ghost + share;
      dom[dim].Hi () = dom[dim].Lo () + ghost - 1;
    }
  }

  DomainIterator<D> iter (dom);
  while (iter.HasNext ())
  {
    os << (*this) (iter.GetLoc ());
    iter.Next ();
  }
}

template<class T, int D>
void Field<T,D>::Recv (int dim, bool right, bool shared)
{
  const CartDomDecomp<D> &dec = _layout.GetDecomp ();

  bool isbnd = right ? dec.IsRightBnd (dim) : dec.IsLeftBnd (dim);
  if (isbnd && _layout.IsOpen (dim)) return;

  int tag = 0; ///@todo generate unique tag
  int prc = right ? dec.GetRight (dim) : dec.GetLeft (dim);
  MpiIStream<T> is (prc, tag, dec.GetComm ());

  Domain<D> dom;
  GetDomainAll (dom);

  int share = _layout.GetShare (dim);
  int ghost = _layout.GetGhost (dim);

  if (shared)
  {
    // no shared layer present
    if (share < 1) return;

    if (right)
    {
      dom[dim].Lo () = dom[dim].Hi () - ghost + 1;
      dom[dim].Hi () = dom[dim].Lo () + share - 1;
    }
    else // if (!right)
    {
      dom[dim].Hi () = dom[dim].Lo () + ghost - 1;
      dom[dim].Lo () = dom[dim].Hi () - share + 1;
    }
  }
  else // if (!shared)
  {
    if (right)
    {
      dom[dim].Lo () = dom[dim].Hi () - ghost + 1;
    }
    else // if (!right)
    {
      dom[dim].Hi () = dom[dim].Lo () + ghost - 1;
    }
  }

  DomainIterator<D> iter (dom);
  while (iter.HasNext ())
  {
    is >> (*this) (iter.GetLoc ());
    iter.Next ();
  }
}

template<class T, int D>
void Field<T,D>::LocalSendRecv (int dim, bool right, bool shared)
{
  if (_layout.IsOpen (dim)) return;

  Domain<D> domsend, domrecv;
  GetDomainAll (domsend);
  GetDomainAll (domrecv);

  int share = _layout.GetShare (dim);
  int ghost = _layout.GetGhost (dim);

  if (shared)
  {
    // no shared layer present
    if (share < 1) return;

    if (right)
    {
      domsend[dim].Hi () = domsend[dim].Lo () + ghost + share - 1;
      domsend[dim].Lo () = domsend[dim].Hi () - share + 1;

      domrecv[dim].Lo () = domrecv[dim].Hi () - ghost + 1;
      domrecv[dim].Hi () = domrecv[dim].Lo () + share - 1;
    }
    else // if (!right)
    {
      domsend[dim].Lo () = domsend[dim].Hi () - ghost - share + 1;
      domsend[dim].Hi () = domsend[dim].Lo () + share - 1;

      domrecv[dim].Hi () = domrecv[dim].Lo () + ghost - 1;
      domrecv[dim].Lo () = domrecv[dim].Hi () - share + 1;
    }
  }
  else // if (!shared)
  {
    if (right)
    {
      domsend[dim].Lo () = domsend[dim].Lo () + ghost + share;
      domsend[dim].Hi () = domsend[dim].Lo () + ghost - 1;

      domrecv[dim].Lo () = domrecv[dim].Hi () - ghost + 1;
    }
    else // if (!right)
    {
      domsend[dim].Hi () = domsend[dim].Hi () - ghost - share;
      domsend[dim].Lo () = domsend[dim].Hi () - ghost + 1;

      domrecv[dim].Hi () = domrecv[dim].Lo () + ghost - 1;
    }
  }

  // int nidx, nghz;
  // for (int i=0; i<D; ++i)
  // {
  //   nidx = _mesh.GetDim (i)-1;
  //   nghz = _layout.GetGhost (dim);
  //   domrecv[i] = domsend[i] = Range (0, nidx);
  // }

  // nidx = _mesh.GetDim (dim)-1;
  // nghz = _layout.GetGhost (dim);

  // if (right)
  // {
  //   domsend[dim] = Range (nidx-2*nghz+1, nidx-nghz);
  //   domrecv[dim] = Range (0, nghz-1);
  // }
  // else
  // {
  //   domsend[dim] = Range (nghz, 2*nghz-1);
  //   domrecv[dim] = Range (nidx-nghz+1, nidx);
  // }

  DomainIterator<D> itersend, iterrecv;
  itersend.Initialize (domsend);
  iterrecv.Initialize (domrecv);
  while (itersend.HasNext () && iterrecv.HasNext ())
  {
    (*this) (iterrecv.GetLoc ()) = (*this) (itersend.GetLoc ());
    itersend.Next ();
    iterrecv.Next ();
  }
}

template<class T, int D>
void Field<T,D>::SyncValues (bool shared)
{
  SAT_DBG_ASSERT (_havegrid);
  const CartDomDecomp<D> &decomp = _layout.GetDecomp ();

  for (int i=0; i<D; ++i)
  {
    if (_layout.GetGhost (i) < 1) continue;

    // When local boundary
    if (decomp.GetSize (i) == 1)
    {
      LocalSendRecv (i, SYNC_RIGHT, shared);
      LocalSendRecv (i, SYNC_LEFT, shared);
      continue;
    }

    // Separate Even/Odd and communicate internal boundaries on patches
    if (decomp.GetPosition (i) % 2 == 0)
    {
      Send (i, SYNC_RIGHT, shared);
      Recv (i, SYNC_RIGHT, shared);
      Recv (i, SYNC_LEFT, shared);
      Send (i, SYNC_LEFT, shared);
    }
    else
    {
      Recv (i, SYNC_LEFT, shared);
      Send (i, SYNC_LEFT, shared);
      Send (i, SYNC_RIGHT, shared);
      Recv (i, SYNC_RIGHT, shared);
    }
  }
}

template<class T, int D>
void Field<T,D>::Sync ()
{
  SyncValues (true);
  UpdateShared ();
  SyncValues (false);
}

#undef SYNC_RIGHT
#undef SYNC_LEFT
