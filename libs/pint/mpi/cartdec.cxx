/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cartdec.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "cartdec.h"

template<int D>
CartDomDecomp<D>::CartDomDecomp ()
{
  Initialize ();
}

template<int D>
void CartDomDecomp<D>::Initialize ()
{
  Initialize (Vector<int,D> (1), Mpi::COMM_WORLD, 0, 1);
  // _ipe = 0;
  // _npe = 1;
  // _lpe = _rpe = 0;

  // _iproc = 0;
  // _nproc = 1;
  // _comm = Mpi::COMM_NULL;
}

template<int D>
void CartDomDecomp<D>::Initialize (const Vector<int,D> &ratio, Mpi::Comm comm,
				   int iproc, int nproc)
{
  Mpi::SetComm (comm);
  _comm = comm;

  if (nproc < 0)
    nproc = Mpi::Nodes ();

  if (iproc < 0)
    iproc = Mpi::Rank ();

  _nproc = nproc;
  _iproc = iproc;

  _npe = ratio;
  SplitProcessors (_npe, nproc);

  _ipe.SetSize (nproc);
  _lpe.SetSize (nproc);
  _rpe.SetSize (nproc);

  for (int i=0; i<nproc; ++i)
    Init (i);
}

template<int D>
void CartDomDecomp<D>::Decompose (Vector<int,D> &vec)
{
  for (int i=0; i<D; ++i)
  {
    while (vec[i] % _npe[i] != 0) ++vec[i];
    vec[i] = vec[i] / _npe[i];
  }
}

template<int D>
int CartDomDecomp<D>::GetPosition (int idim, int iproc) const
{
  SAT_DBG_ASSERT (iproc<_nproc);
  SAT_DBG_ASSERT (idim < D)
  return _ipe[iproc][idim];
}

template<int D>
int CartDomDecomp<D>::GetLeft (int idim, int iproc) const
{
  SAT_DBG_ASSERT (iproc<_nproc);
  SAT_DBG_ASSERT (idim < D)
  return _lpe[iproc][idim];
}

template<int D>
int CartDomDecomp<D>::GetRight (int idim, int iproc) const
{
  SAT_DBG_ASSERT (iproc < _nproc);
  SAT_DBG_ASSERT (idim < D)
  return _rpe[iproc][idim];
}

template<int D>
void CartDomDecomp<D>::Init (int iproc)
{
  int ndiv = 1;
  for (int i=0; i<D; ++i)
  {
    _ipe[iproc][i] = (iproc / ndiv) % _npe[i];

    if (_npe[i] == 1)
    {
      _lpe[iproc][i] = iproc;
      _rpe[iproc][i] = iproc;
    }
    else if (_ipe[iproc][i] == 0)
    {
      _lpe[iproc][i] = iproc + (_npe[i]-1) * ndiv;
      _rpe[iproc][i] = iproc + ndiv;
    }
    else if (_ipe[iproc][i] == _npe[i]-1)
    {
      _lpe[iproc][i] = iproc - ndiv;
      _rpe[iproc][i] = iproc - (_npe[i]-1) * ndiv;
    }
    else
    {
      _lpe[iproc][i] = iproc - ndiv;
      _rpe[iproc][i] = iproc + ndiv;
    }

    ndiv *= _npe[i];
  }
}

template<int D>
void CartDomDecomp<D>::SplitProcessors (Vector<int,D>& ratio, int nproc)
{
  Vector<int,D> split = ratio;

  for (;split.Mult () < nproc;)
  {
    for (int dim=0; dim<D;++dim)
    {
      int idx = 0;
      while (split.Mult () < nproc && idx++ < ratio[dim])
	++split[dim];
    }
  }
  SAT_ASSERT_MSG (split.Mult () == nproc, "Unable to split processors"
		  " using given ratio");
  ratio = split;
}

template class CartDomDecomp<1>;
template class CartDomDecomp<2>;
template class CartDomDecomp<3>;
