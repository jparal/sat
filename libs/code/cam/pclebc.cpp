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
bool CAMCode<B,T,D>::PcleBC (TSpecie *sp, size_t id,
			     PosVector &pos, VelVector &vel)
{
  bool remove = false;

  for (int i=0; i<D; ++i)
  {
    if_pf (pos[i] <= _pmin[i])
    {
      pclecmd_t cmd;
      if (_layop.IsOpen (i) && _layop.GetDecomp ().IsLeftBnd (i))
      {
	// @todo treat boundary more appropriately
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
	// @todo treat boundary more appropriately
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
