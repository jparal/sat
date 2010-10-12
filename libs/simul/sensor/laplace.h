/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   laplace.h
 * @brief  compute Laplace of the given field
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_LAPLACE_H__
#define __SAT_LAPLACE_H__

#include "sensor.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @revision{1.1}
 * @reventry{2010/10, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class LaplaceSensor : public Sensor
{
public:
  using Sensor::SaveData;

  void Initialize (ConfigFile &cfg, const char *id,
		   Field<Vector<T,R>,D> *F)
  {
    Sensor::Initialize (cfg, id);
    _F = F;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    _laplace.Initialize (_F->GetMesh(), _F->GetLayout());
    CalcLaplace (*_F, _laplace);
    iomng.Write (_laplace, stime, GetTag ());
    _laplace.Free ();
  }

private:
  void CalcLaplace (const Field<Vector<T,R>,D>& F,
		    Field<Vector<T,R>,D>& L)
  {
    Domain<D> dom;
    F.GetDomain (dom);
    DomainIterator<D> it (dom);

    Vector<T,R> lap;
    do
    {
      CartStencil::Lapl (F, it, lap);
      L(it) = lap;
    }
    while (it.Next ());
  }

  Field<Vector<T,R>,D> *_F;
  Field<Vector<T,R>,D> _laplace;
};

/// @}

#endif /* __SAT_LAPLACE_H__ */
