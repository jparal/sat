/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pclebc.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
bool CAMCode<B,T,D>::PcleBC (TSpecie *sp, size_t id, TParticle &pcle)
{
  bool remove = false;
  PosVector &pos = pcle.pos;

  for (int i=0; i<D; ++i)
  {
    if_pf (pos[i] <= _pmin[i])
    {
      pclecmd_t cmd;
      if (_layop.IsOpen (i) && _layop.GetDecomp ().IsLeftBnd (i))
      {
	cmd = PCLE_CMD_REMOVE;
      }
      else
      {
        cmd = PCLE_CMD_SEND_DIM(PCLE_CMD_SEND_LEFT,i);
        pos[i] += _pmax[i];
      }

      sp->Exec (id, cmd);
      remove = true;
    }

    if_pf (pos[i] >= _pmax[i])
    {
      pclecmd_t cmd;
      if (_layop.IsOpen (i) && _layop.GetDecomp ().IsRightBnd (i))
      {
	cmd = PCLE_CMD_REMOVE;
      }
      else
      {
        cmd = PCLE_CMD_SEND_DIM(PCLE_CMD_SEND_RIGHT,i);
        pos[i] -= _pmax[i];
      }

      sp->Exec (id, cmd);
      remove = true;
    }
  }

  return remove;
}

template<class B, class T, int D>
void CAMCode<B,T,D>::PcleSync (TSpecie *sp, ScaField &dn, VecField &us)
{
  /**********************************************************************/
  /* Synchronize particles:                                             */
  /* 1) repeat till we have any particles marked for transfer           */
  /*   1a) synchronize                                                  */
  /*   1b) apply boundary condition to the incoming particles           */
  /*   1c) update a position of newcomers (already done in the previous */
  /*       calling of boundary conditions                               */
  /*   1d) update moments dnsb and Usb                                  */
  /* 2) remove old particles                                            */
  /**********************************************************************/
  BilinearWeightCache<T,D> cache;
  int send = 0, recv = 0, clean = 0;
  sp->Sync (&send, &recv);

  TSpecieCommandIterator iter = sp->GetCommandIterator (PCLE_CMD_ARRIVED);
  while (iter.HasNext ())
  {
    const PcleCommandInfo& info = iter.Next (true);
    TParticle &pcle = sp->Get (info.pid);

    FillCache (pcle.pos, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dn, cache, (T)1.);
    CartStencil::BilinearWeightAdd (us, cache, pcle.vel);
  }

  sp->Clean (&clean);
}
