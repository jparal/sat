/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   simtime.cxx
 * @brief  Simulation time tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/02, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "simul/misc/simtime.h"
#include "sat.h"
#include <iostream>
using namespace std;

SUITE (SimulTimeSuite)
{
  TEST (InitializeTest)
  {
    Ref<SimulTime> st = new SimulTime;
    {
      Ref<SimulTime> tmp = Ref<SimulTime>::New ();
      // tmp->DecRef ();
    }
    st->Initialize (0.0025, 1000.);
    st->Next ();

    CHECK (st->Iter () == 1);
    CHECK (st->ItersMax () == 400000);
    CHECK (st->ItersLeft () == 399999);

    ConfigFile cfg;
    cfg.ReadFile ("simtime.sin");
    ConfigEntry &entry = cfg.GetEntry ("simul");
    st->Initialize (entry, 0);
    st->Next ();

    CHECK (st->Iter () == 1);
    CHECK (st->ItersMax () == 400000);
    CHECK (st->ItersLeft () == 399999);
  }
}
