/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   specie.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "specie.h"
#include "math/rand/maxwell.h"
#include "simul/field/cartstencil.h"


template<class T, int D>
int Specie<T,D>::Clean (int *clean)
{
  int cleaned = 0;

  size_t lcmd = _cmdqueue.GetSize ();
  PcleCommandInfo *linfo;

  if (lcmd == 0)
  {
    if (clean != NULL) *clean = cleaned;
    return 0;
  }

  do
  {
    linfo = &(_cmdqueue.Get (--lcmd));
  }
  while ((!(linfo->cmd) || (linfo->cmd & PCLE_CMD_REMOVE)) && lcmd>0);

  for (int i=(int)_cmdqueue.GetSize ()-1; i>=0; --i)
  {
    PcleCommandInfo& info = _cmdqueue.Get (i);

    if (info.cmd & PCLE_CMD_REMOVE)
    {
      info.cmd = PCLE_CMD_NONE;
      size_t rmvd = _pcles.DeleteIndexFast (info.pid);

      if (linfo->pid == rmvd)
      {
	info.cmd = linfo->cmd;
	linfo->cmd = PCLE_CMD_NONE;

	do
	{
	  linfo = &(_cmdqueue.Get (--lcmd));
	}
	while ((!(linfo->cmd) || (linfo->cmd & PCLE_CMD_REMOVE)) && lcmd>0);
      }

      ++cleaned;
    }
  }

  if (clean != NULL) *clean = cleaned;
  return cleaned;
}

template<class T, int D>
int Specie<T,D>::Send (int dim, bool left)
{
  const CartDomDecomp<D> &dec = _layout.GetDecomp ();
  bool isbnd = left ? dec.IsLeftBnd (dim) : dec.IsRightBnd (dim);
  if (isbnd && _layout.IsOpen (dim))
    return 0;

  int tag = 0; ///@todo generate unique tag
  int prc = left ? dec.GetLeft (dim) : dec.GetRight (dim);
  MpiOStream<T> os1 (prc, tag, dec.GetComm ());
  MpiOStream<pclecmd_t> os2 (prc, tag+2, dec.GetComm ());

  int nsend = 0;
  pclecmd_t off = left ? PCLE_CMD_SEND_LEFT : PCLE_CMD_SEND_RIGHT;
  pclecmd_t cmd = PCLE_CMD_SEND_DIM(off,dim);
  CommandIterator iter = GetCommandIterator (cmd);
  while (iter.HasNext ())
  {
    PcleCommandInfo& info = iter.Next (true);
    const TParticle &pcle = _pcles.Get (info.pid);
    for (int i=0; i<D; ++i) os1 << pcle.pos[i];
    for (int i=0; i<3; ++i) os1 << pcle.vel[i];
    os2 << info.cmd;

    info.cmd = PCLE_CMD_REMOVE;

    ++nsend;
  }

  return nsend;
}

template<class T, int D>
int Specie<T,D>::Recv (int dim, bool left)
{
  const CartDomDecomp<D> &dec = _layout.GetDecomp ();
  bool isbnd = left ? dec.IsLeftBnd (dim) : dec.IsRightBnd (dim);
  if (isbnd && _layout.IsOpen (dim))
    return 0;

  int tag = 0; ///@todo generate unique tag
  int prc = left ? dec.GetLeft (dim) : dec.GetRight (dim);
  MpiIStream<T> is1 (prc, tag, dec.GetComm ());
  MpiIStream<pclecmd_t> is2 (prc, tag+2, dec.GetComm ());

  pclecmd_t cmd;
  int nrecv = 0;
  TParticle pcle;
  PcleCommandInfo info;
  while (is1.HasNext ())
  {
    for (int i=0; i<D; ++i) is1 >> pcle.pos[i];
    for (int i=0; i<3; ++i) is1 >> pcle.vel[i];
    is2 >> cmd;

    info.pid = _pcles.Push (pcle);
    info.cmd = cmd | PCLE_CMD_ARRIVED;

    // the push is actually 'sorted insert' since new particle is on the end
    _cmdqueue.Push (info);

    ++nrecv;
  }

  return nrecv;
}

template<class T, int D>
bool Specie<T,D>::Sync (int *send, int *recv)
{
  int lsend = 0, lrecv = 0;

  for (int i=0; i<D; ++i)
  {
    const CartDomDecomp<D> &decomp = _layout.GetDecomp ();

    // When local boundary
    if (decomp.GetSize (i) == 1)
    {
      continue;
    }

    // Separate Even/Odd and communicate internal boundaries on patches
    if (decomp.GetPosition (i) % 2 == 0)
    {
      lsend += Send (i, false);
      lrecv += Recv (i, false);
      lrecv += Recv (i, true);
      lsend += Send (i, true);
    }
    else
    {
      lrecv += Recv (i, true);
      lsend += Send (i, true);
      lsend += Send (i, false);
      lrecv += Recv (i, false);
    }
  }

  if (send != NULL) *send += lsend;
  if (recv != NULL) *recv += lrecv;

  if (lsend == 0 && lrecv == 0)
    return false;
  else
    return true;
}

template<class T, int D>
void Specie<T,D>::Check (int opt)
{
#ifdef SAT_DEBUG
  size_t npcle = _pcles.GetSize ();

  switch (opt)
  {
  case 1:
  {
    size_t pid = _cmdqueue.Get (0).pid;
    for (int i=1; i<(int)_cmdqueue.GetSize (); i++)
    {
      const PcleCommandInfo &info = _cmdqueue.Get (i);
      if (info.cmd)
      {
	SAT_ASSERT (pid < info.pid);
	pid = info.pid;
      }
    }
  }
  break;

  default:

    for (int i=0; i<(int)_cmdqueue.GetSize (); i++)
    {
      const PcleCommandInfo &info = _cmdqueue.Get (i);
      if (info.cmd) SAT_ASSERT (info.pid < npcle);
    }
    break;
  };

#endif  // SAT_DEBUG
}

template<class T, int D>
size_t Specie<T,D>::GetTotalSize () const
{
  long total = GetSize ();
  Mpi::SumReduce (&total);

  return (size_t)total;
}

/*******************/
/* Specialization: */
/*******************/

#define SPECIE_SPECIALIZE_DIM(type,dim) \
  template class Specie<type,dim>;

#define SPECIE_SPECIALIZE(type) \
  SPECIE_SPECIALIZE_DIM(type,1) \
  SPECIE_SPECIALIZE_DIM(type,2) \
  SPECIE_SPECIALIZE_DIM(type,3)

SPECIE_SPECIALIZE(float)
SPECIE_SPECIALIZE(double)
