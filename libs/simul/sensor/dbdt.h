/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   dbdt.h
 * @brief  dB/dt = - curl E seonsor
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DBDT_H__
#define __SAT_DBDT_H__

#include "sensor.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief dB/dt = - curl E sensor
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class DbDtVecFieldSensor : public Sensor
{
public:
  using Sensor::SaveData;

  void Initialize (Field<Vector<T,R>,D> *E,
		   Field<Vector<T,R>,D> *B,
		   const char *id, ConfigFile &cfg)
  {
    Sensor::Initialize (id, cfg);
    _E = E; _B = B;
  }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    _dbdt.Initialize (_B->GetMesh(), _B->GetLayout());
    CalcDbdt (*_E, _dbdt);
    iomng.Write (_dbdt, stime, GetTag ());
    _dbdt.Free ();
  }

private:
  void CalcDbdt (const Field<Vector<T,R>,D>& E, Field<Vector<T,R>,D>& dbdt)
  {
    Domain<D> dom;
    _dbdt.GetDomain (dom);
    DomainIterator<D> itb (dom);
    _E->GetDomainAll (dom);
    dom.HiAdd (-1);
    DomainIterator<D> ite (dom);

    Vector<T,R> curle;
    while (itb.HasNext ())
    {
      CartStencil::Curl (*_E, ite, curle);
      _dbdt (itb.GetLoc ()) = -curle;
      itb.Next ();
      ite.Next ();
    }
  };

  Field<Vector<T,R>,D> _dbdt;
  Field<Vector<T,R>,D> *_E;
  Field<Vector<T,R>,D> *_B;
};

/// @}

#endif /* __SAT_DBDT_H__ */
