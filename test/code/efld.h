/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cam.h
 * @brief  CAM tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/10, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TEST_CAM_H__
#define __SAT_TEST_CAM_H__

#include "sattest.h"
#include "test/tester/macros.h"
#include "sat.h"

#define EPS 5.e-5
#define DIM 1

template<class T>
class EfldTestCAMCode : public CAMCode<EfldTestCAMCode<T>,T,DIM>
{
public:
  typedef CAMCode<EfldTestCAMCode<T>,T,DIM> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef Particle<T,DIM> TParticle;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;
  typedef typename TBase::FldVector FldVector;

  /// Constructor
  EfldTestCAMCode ()
  {
  };

  virtual ~EfldTestCAMCode () { };

  void Check ()
  {
    _b.Initialize (this->_meshb, this->_layob);
    _u.Initialize (this->_meshu, this->_layou);
    _n.Initialize (this->_meshu, this->_layou);

    RandomGen<T> rnd;
    MaxwellRandGen<T> mxw;
    Domain<DIM> dom;

    _b.GetDomain (dom); DomainIterator<DIM> itb (dom);
    while (itb.HasNext ()) {
      _b(itb.GetLoc ()) = Vector<T,3> (rnd.Get (), rnd.Get (), rnd.Get ());
      itb.Next ();
    }

    _u.GetDomain (dom); DomainIterator<DIM> itu (dom);
    while (itu.HasNext ()) {
      _u(itu.GetLoc ()) = Vector<T,3> (mxw.Get (), mxw.Get (), mxw.Get ());
      itu.Next ();
    }

    _b.GetDomain (dom); DomainIterator<DIM> itn (dom);
    while (itn.HasNext ())
    { _n(itn.GetLoc ()) = 1. + mxw.Get (); itn.Next (); }

    this->CalcE (_b, _u, _n, false);

    FldVector cb, b, u, e, ee, dx, jb, cbb;
    dx = 1.;
    T n, dbydx, dbzdx;
    for (int i=0; i<10; ++i)
    {
      //      int ip1 = i+1, ip0 = i+0;
      int ib0 = i  , ib1 = i+1;
      int iu0 = i+1, iu1 = i+2;
      int in0 = i+1, in1 = i+2;

      ee = this->_E(i+1);

      b[0] = 0.5 * (_b(ib0)[0] + _b(ib1)[0]);
      b[1] = 0.5 * (_b(ib0)[1] + _b(ib1)[1]);
      b[2] = 0.5 * (_b(ib0)[2] + _b(ib1)[2]);

      u[0] = 0.5 * (_u(iu0)[0] + _u(iu1)[0]);
      u[1] = 0.5 * (_u(iu0)[1] + _u(iu1)[1]);
      u[2] = 0.5 * (_u(iu0)[2] + _u(iu1)[2]);

      n = 1./ (0.5 * (_n(in0) + _n(in1)));

      dbydx = (_b(ib1)[1] - _b(ib0)[1])/dx[0];
      dbzdx = (_b(ib1)[2] - _b(ib0)[2])/dx[0];

      cb[0] = 0.;
      cb[1] = -dbzdx;
      cb[2] = dbydx;

      jb[0] = u[1] * b[2] - u[2] * b[1];
      jb[1] = u[2] * b[0] - u[0] * b[2];
      jb[2] = u[0] * b[1] - u[1] * b[0];

      cbb[0] = cb[1] * b[2] - cb[2] * b[1];
      cbb[1] = cb[2] * b[0] - cb[0] * b[2];
      cbb[2] = cb[0] * b[1] - cb[1] * b[0];

      e[0] = n * (cbb[0] - jb[0]);
      e[1] = n * (cbb[1] - jb[1]);
      e[2] = n * (cbb[2] - jb[2]);

      // DBG_INFO ("i = "<<i);
      // DBG_INFO ("  b   = "<<b);
      // DBG_INFO ("  u   = "<<u);
      // DBG_INFO ("  n   = "<<1./n);
      // DBG_INFO ("  cb  = "<<cb);
      // DBG_INFO ("  jb  = "<<jb);
      // DBG_INFO ("  cbb = "<<cbb);
      // DBG_INFO ("  e   = "<<e<<" == "<<ee);
      SAT_ASSERT(Math::Abs (e[0] - ee[0]) < EPS);
      SAT_ASSERT(Math::Abs (e[1] - ee[1]) < EPS);
      SAT_ASSERT(Math::Abs (e[2] - ee[2]) < EPS);
    }
  }

private:
  VecField _b, _u;
  ScaField _n;
};

#endif /* __SAT_TEST_CAM_H__ */
