/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   sensor.cxx
 * @brief  Sensor tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "satsimul.h"

SUITE (SensorSuite)
{
  TEST (ManagerTest)
  {
    ConfigFile cfg;
    cfg.ReadFile ("sensor.sin");

    SensorManager mng;
    mng.Initialize (cfg);

    Field<float,3> fld (10, 20, 30);
    fld = 1.123;
    {
      ScaFieldSensor<float,3> *sens = new ScaFieldSensor<float,3>;
      sens->Initialize (&fld, "magfield", cfg);
      mng.AddSensor (sens);
    }
    {
      ScaFieldSensor<float,3> *sens = new ScaFieldSensor<float,3>;
      sens->Initialize (&fld, "elfield", cfg);
      mng.AddSensor (sens);
    }

    SimulTime st;
    st.Initialize (cfg, 1);
    mng.SetNextOutput (st);

    DBG_INFO ("MaxIter: "<<st.ItersMax ());

    do
    {
      while (st.Next ())
      { DBG_INFO ("Iter: "<<st.Iter ()); }

      mng.Save ("magfield", st);
      mng.Save ("elfield", st);

      mng.SetNextOutput (st);
    }
    while (st.Iter () < st.ItersMax ());
  }

  TEST (BaseTest)
  {
    ConfigFile cfg;
    cfg.ReadFile ("sensor.sin");

    Sensor sens;
    sens.Initialize ("magfield", cfg);
  }
}
