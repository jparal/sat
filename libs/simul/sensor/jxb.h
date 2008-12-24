/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   jxb.h
 * @brief  compute curl J x B term from mag. field advancement
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_JXB_H__
#define __SAT_JXB_H__

#include "sensor.h"
#include "satio.h"

/** @addtogroup simul_sensor
 *  @{
 */

/**
 * @brief Compute @f$ \nabla \times (\mathbf{J} \times \mathbf{B})/\rho_c @f$
 *        term from magnetic field advancement.
 * This sensor is for debug purposes and compute one of the terms from magnetic
 * field advancing in functions CAMCode::CalcE and CAMCode::CalcB :
 * @f[
 * \frac{\partial \mathbf{B}}{\partial t} = ... + \nabla \times
 *      \frac{\mathbf{J} \times \mathbf{B}}{\rho_c}
 *      + ...
 * @f]
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class JxBSensor : public Sensor
{
public:
  using Sensor::SaveData;

  void Initialize (Field<Vector<T,R>,D> *J,
		   Field<Vector<T,R>,D> *B,
		   Field<T,D> *rhoc,
		   const char *id, ConfigFile &cfg)
  {
    Sensor::Initialize (id, cfg);
    _J = J; _B = B; _rhoc = rhoc;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    _jxb.Initialize (_B->GetMesh(), _B->GetLayout());
    CalcJxB (*_J, *_B, *_rhoc, _jxb);
    iomng.Write (_jxb, stime, GetTag ());
    _jxb.Free ();
  }

private:
  void CalcJxB (const Field<Vector<T,R>,D>& J, const Field<Vector<T,R>,D>& B,
		const Field<T,D>& rhoc, Field<Vector<T,R>,D>& jxb)
  {
    Domain<D> dom;
    J.GetDomain (dom);
    DomainIterator<D> itj (dom);
    B.GetDomain (dom);
    DomainIterator<D> itb (dom);
    rhoc.GetDomain (dom);
    DomainIterator<D> itr (dom);

    T rho;
    while (itb.HasNext ())
    {
      rho = rhoc(itr.GetLoc());

      if (rho > 0.0001)
	_jxb (itb.GetLoc ()) = (J(itj.GetLoc()) % B(itb.GetLoc())) / rho;
      else
	_jxb (itb.GetLoc ()) = 0.;

      itb.Next ();
      itj.Next ();
      itr.Next ();
    }
  };

  Field<Vector<T,R>,D> _jxb;
  Field<Vector<T,R>,D> *_J;
  Field<Vector<T,R>,D> *_B;
  Field<T,D> *_rhoc;
};


/** @} */

#endif /* __SAT_JXB_H__ */
