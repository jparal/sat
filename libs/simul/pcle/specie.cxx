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
#include "math/rand/maxwgen.h"
#include "simul/field/cartstencil.h"

template<class T, int D>
void Specie<T,D>::Initialize (const ConfigEntry &cfg,
			      const Mesh<D> mesh,
			      const Layout<D> layout)
{
  _mesh = mesh;
  _layout = layout;
  _name = cfg.GetName ();

  try
  {
    cfg.GetValue ("pcles", _ng);
    cfg.GetValue ("beta", _beta);
    cfg.GetValue ("rvth", _rvth);
    cfg.GetValue ("rmds", _rmds);
    cfg.GetValue ("qms", _qms);

    ConfigEntry &v0 = cfg ["v0"];
    for (int i=0; i<3; ++i) _vs[i] = v0[i];
  }
  catch (ConfigFileException &exc)
  {
    DBG_ERROR ("Specie::Initialize: exception during: "<<
	       cfg.GetPath ());
  }

  _vthpa = Math::Sqrt (_beta / _rmds);
  _vthpe = Math::Sqrt (_rvth * _vthpa);

  _sm = _rmds / _ng;
  _sq = _qms * _sm;
}

template<class T, int D>
void Specie<T,D>::LoadPcles (const Field<T,D> &dn,
			     const Field<Vector<T,3>,D> &u, Vector<T,3> b)
{
  double bb;
  T vpar, vper1, vper2;
  Vector<double,3> v1, v2;
  TParticle pcle;
  T dnl;
  Vector<T,D> pos;
  int np;

  b.Normalize ();

  bb = Math::Sqrt (b[1]*b[1] + b[2]*b[2]);
  if (bb > 0.05)
  {
    v1[0] = 0.;
    v1[1] =   b[2] / bb;
    v1[2] = - b[1] / bb;
  }
  else
  {
    bb = Math::Sqrt (b[0]*b[0] + b[1]*b[1]);
    v1[0] =   b[1] / bb;
    v1[1] = - b[0] / bb;
    v1[2] = 0.;
  }
  v2 = b % v1;

  MaxwellRandGen<T> maxwpa (Vthpar ());
  MaxwellRandGen<T> maxwpe (Vthper ());

  Domain<D> dom;
  for (int i=0; i<D; ++i)
    // Go from 0 .. number of vertexes - 2
    dom[i] = Range (0, _mesh.GetDim (i)-2);

  DomainIterator<D> it (dom);
  while (it.HasNext ())
  {
    CartStencil::Average (dn, it, dnl);
    np = (int)(dnl * _ng);

    for (int i=0; i<np; ++i)
    {
      for (int j=0; j<D; ++j)
	pos[j] = _rnd.Get () + (T)it.GetLoc (j);

      vper1 = maxwpe.Get ();
      vper2 = maxwpe.Get ();
      vpar  = maxwpa.Get ();

      pcle.pos = pos;
      CartStencil::BilinearWeight (u, pos, pcle.vel);
      pcle.vel += b * vpar + v1 * vper1 + v2 * vper2;

      _pcles.Push (pcle);
    }

    it.Next ();
  }
}

template<class T, int D>
int Specie<T,D>::Clean (int *clean)
{
  int cleaned = 0;

  size_t icmdlast = _cmdqueue.GetSize ();
  PcleCommandInfo *ilast;

  do
  {
    ilast = &(_cmdqueue.Get (--icmdlast));
  }
  while (!(ilast->cmd) || (ilast->cmd & PCLE_CMD_REMOVE));

  for (int i=(int)_cmdqueue.GetSize ()-1; i>=0; --i)
  {
    PcleCommandInfo& info = _cmdqueue.Get (i);

    if (info.cmd & PCLE_CMD_REMOVE)
    {
      info.cmd = PCLE_CMD_NONE;
      size_t rmvd = _pcles.DeleteIndexFast (info.pid);

      if (ilast->pid == rmvd)
      {
	info.cmd = ilast->cmd;
	ilast->cmd = PCLE_CMD_NONE;

	do
	{
	  ilast = &(_cmdqueue.Get (--icmdlast));
	}
	while (!(ilast->cmd) || (ilast->cmd & PCLE_CMD_REMOVE));
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
