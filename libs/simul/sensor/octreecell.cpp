/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   octreecell.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2011/01, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"

template<class T, int D>
void OctreeCell<T,D>::Initialize (Vector<T,D> vmin, Vector<T,D> vmax,
                                  int levmin, int levmax,
                                  float epsglo, float epsloc,
                                  bool balance)
{
  SAT_ASSERT (vmin < vmax);
  SAT_ASSERT (levmin < levmax);

  _vmin = vmin;
  _vmax = vmax;
  _levelMin = levmin;
  _levelMax = levmax;
  _epsglo = epsglo;
  _epsloc = epsloc;
  _balance = balance;

  _cell.DeleteAll ();
  _dfnc.DeleteAll ();

  DistFncInfo dfnfo;
  for (int i=0; i<MetaPow<2,D>::Is; ++i)
    _dfnc.Push (dfnfo);

  // Construction of the primitive cell
  if (D == 1)
  {
    VPosVector &pos1 = _dfnc[0].pos;
    VPosVector &pos2 = _dfnc[1].pos;

    pos1[0] = _vmin[0];
    pos2[0] = _vmax[0];
  }
  else if (D == 2)
  {
    VPosVector &pos1 = _dfnc[0].pos;
    VPosVector &pos2 = _dfnc[1].pos;
    VPosVector &pos3 = _dfnc[2].pos;
    VPosVector &pos4 = _dfnc[3].pos;

    pos1[0] = pos4[0] = _vmin[0];
    pos2[0] = pos3[0] = _vmax[0];

    pos1[1] = pos2[1] = _vmin[1];
    pos3[1] = pos4[1] = _vmax[1];
  }
  else if (D == 3)
  {
    VPosVector &pos1 = _dfnc[0].pos;
    VPosVector &pos2 = _dfnc[1].pos;
    VPosVector &pos3 = _dfnc[2].pos;
    VPosVector &pos4 = _dfnc[3].pos;
    VPosVector &pos5 = _dfnc[4].pos;
    VPosVector &pos6 = _dfnc[5].pos;
    VPosVector &pos7 = _dfnc[6].pos;
    VPosVector &pos8 = _dfnc[7].pos;

    pos1[0] = pos4[0] = pos5[0] = pos8[0] = _vmin[0];
    pos2[0] = pos3[0] = pos6[0] = pos7[0] = _vmax[0];

    pos1[1] = pos2[1] = pos5[1] = pos6[1] = _vmin[1];
    pos3[1] = pos4[1] = pos7[1] = pos8[1] = _vmax[1];

    pos1[1] = pos2[1] = pos3[1] = pos4[1] = _vmin[2];
    pos5[1] = pos6[1] = pos7[1] = pos8[1] = _vmax[2];
  }
  else
    SAT_ASSERT (false)

      for (int i=0; i<MetaPow<2,D>::Is; ++i)
      {
	DistFncInfo &dfnfo = _dfnc[i];
	dfnfo.fnc = DistFunction (dfnfo.pos);
      }

  OctreeCellInfo ocnfo;
  ocnfo.lev = 0;
  ocnfo.mom = -1;
  ocnfo.rel = 0;
  ocnfo.son = -1;
  ocnfo.ind = 1;
  for (int i=0; i<MetaPow<2,D>::Is; ++i)
    ocnfo.idx[i] = i;

  Vector<T,D> vel = _vmax - _vmin;
  _volMesh = vel.Mult ();
  _nDel = 0;

  // divide cell up to levelMin
  int prev = 0;
  const int ncells = MetaPow<2,D>::Is;
  for (int ilev=0; ilev<_levelMin; ++ilev)
  {
    for (int icell=prev; icell<prev+Math::Pow (ncells, ilev); ++icell)
      DivideCell (icell);

    prev = prev+Math::Pow (ncells, ilev);
  }
}
