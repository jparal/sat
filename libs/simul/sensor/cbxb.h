/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cbxb.h
 * @brief  Compute @f$ (\nabla \times \mathbf{B} \times \mathbf{B})/\rho_c @f$
 *         term from magnetic field advancement.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CBXB_H__
#define __SAT_CBXB_H__

#include "sensor.h"
#include "satio.h"

/** @addtogroup simul_sensor
 *  @{
 */

/**
 * @brief Compute @f$ (\nabla \times \mathbf{B} \times \mathbf{B})/\rho_c @f$
 *         term from magnetic field advancement.
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class CurlBxBSensor : public Sensor
{
public:
  using Sensor::SaveData;

  void Initialize (Field<Vector<T,R>,D> *B, Field<T,D> *rhoc,
		   const char *id, ConfigFile &cfg)
  {
    Sensor::Initialize (id, cfg);
    _B = B; _rhoc = rhoc;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    Mesh<D> mesh = _B->GetMesh ();
    mesh.Center () = Cell;
    mesh.Dim () -= 1;
    Layout<D> layout = _B->GetLayout ();

    _cbxb.Initialize (mesh, layout);
    CalcCurlBxB (*_B, *_rhoc, _cbxb);
    iomng.Write (_cbxb, stime, GetTag ());
    _cbxb.Free ();
  }

private:
  void CalcCurlBxB (const Field<Vector<T,R>,D>& B, const Field<T,D>& rhoc,
		    Field<Vector<T,R>,D>& cbxb)
  {
    Domain<D> dom;
    _cbxb.GetDomain (dom);
    DomainIterator<D> ito (dom);
    B.GetDomain (dom);
    dom.HiAdd (-1);
    DomainIterator<D> itb (dom);
    rhoc.GetDomain (dom);
    dom.HiAdd (-1);
    DomainIterator<D> itm (dom);

    Vector<T,R> bc, cb;
    T nc;
    while (ito.HasNext ())
    {
      CartStencil::Curl (B, itb, cb);
      CartStencil::Average (B, itb, bc);
      CartStencil::Average (rhoc, itm, nc);

      nc = 1./nc;
      _cbxb (ito.GetLoc ()) = nc * (cb % bc);

      ito.Next ();
      itb.Next ();
      itm.Next ();
    }
  };

  Field<Vector<T,R>,D> _cbxb;
  Field<T,D> *_rhoc;
  Field<Vector<T,R>,D> *_B;
};

/** @} */

#endif /* __SAT_CBXB_H__ */
