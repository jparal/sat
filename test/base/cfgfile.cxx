
#include <iostream>

#include "sattest.h"
#include "base/satcfgfile.h"

SUITE (CfgfileSuite)
{
  TEST (ConfigEntryTest)
  {
    ConfigFile cfg;

    try
    {
      cfg.ReadFile ("cfgfile.sin");
      cfg.SetAutoConvert ();
    }
    catch (ParseException& ex)
    {
      printf ("error on line %d: %s\n", ex.GetLine(), ex.GetError());
    }

    bool ioflush, restart;
    CHECK (cfg.GetValue ("sat.ioflush", ioflush, false));
    CHECK (ioflush == false);

    ConfigEntry &entry = cfg.GetEntry ("output.sensors");
    bool enable;
    entry[0].GetValue ("enable", enable);
    CHECK (enable);

    CHECK (cfg.GetValue ("simul.restart", restart, false));
    CHECK (restart == false);

    ConfigEntry &pcles = cfg.GetEntry ("plasma.pcles");
    int npcl  = pcles[0];
    CHECK (npcl == 70);

    CHECK (cfg.Exists ("output.runname"));

    ConfigEntry &pos = cfg.GetEntry ("position");
    Vector<float, 3> vec;
    for (int i=0; i<pos.GetLength (); ++i)
    {
      pos.GetValue (i, vec);
      DBG_INFO (vec);
    }
  }

  TEST (ParserTest)
  {
  }
}
