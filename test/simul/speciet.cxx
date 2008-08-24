/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   specie.cxx
 * @brief  tests of the Specie class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "sat.h"

#define TYPE float
#define DIM 1
#define LEN 50
#define COMMUNICATE 0.1

typedef Field<Vector<TYPE,3>,DIM> VecField;
typedef Field<TYPE,DIM> ScaField;

SUITE (SpecieSuite)
{
  TEST (InitTest)
  {
    Mpi::Initialize (g_pargc, g_pargv);
    int iproc = Mpi::Rank ();
    int nproc = Mpi::Nodes ();

    ConfigFile cfg;
    cfg.ReadFile ("specie.sin");
    cfg.SetAutoConvert (true);

    SAT_ASSERT (cfg.Exists ("plasma.specie.proton"));
    ConfigEntry &proton = cfg.GetEntry ("plasma.specie.proton");

    Mesh<DIM> mesh;
    mesh.Initialize (Loc<DIM> (LEN), Vector<double,DIM> (0.5),
		     Vector<double,DIM> (0.5), Cell);
    CartDomDecomp<DIM> decomp;
    Loc<DIM> ratio = 1;
    decomp.Initialize (ratio, Mpi::COMM_WORLD);

    Layout<DIM> layout;
    layout.Initialize (Loc<DIM> (1), Loc<DIM> (0),
		       Vector<bool,DIM> (false), decomp);

    Specie<TYPE,DIM> sp;
    typedef Specie<TYPE,DIM>::CommandIterator CommandIterator;
    sp.Initialize (proton, mesh, layout);
    Vector<TYPE,3> b = 1.;
    Field<Vector<TYPE,3>,DIM> u;
    Field<TYPE,DIM> dn;
    u.Initialize (mesh, layout);
    dn.Initialize (mesh, layout);
    u = Vector<TYPE,3> (1.,0.,0.);
    dn = 1.;

    sp.LoadPcles (dn, u, b);
    DBG_INFO ("Count: "<<sp.GetSize ());

    // sp.Exec (sp.GetSize ()-1, PCLE_CMD_TRACE);
    // sp.Remove (10);
    // sp.Remove (12);
    // sp.Remove (13);
    // sp.Remove (14);
    // CommandIterator iter = sp.GetCommandIterator (PCLE_CMD_REMOVE);
    // while (iter.HasNext ())
    // {
    //   PcleCommandInfo &info = iter.Next (true);
    //   DBG_INFO ("Pcle "<<info.pid);
    // };

    int send = 0, recv = 0;
    int tocomm = (int)(sp.GetSize () * COMMUNICATE);
    RandomGen<double> rnd;
    for (int i=0; i<tocomm-iproc; ++i)
    {
      int ipcle = rnd.Get ((uint32_t)sp.GetSize ());
      if (iproc == 0)
	sp.Exec (ipcle, PCLE_CMD_SEND_DIM(PCLE_CMD_SEND_RIGHT,0));
      else
	sp.Exec (ipcle, PCLE_CMD_SEND_DIM(PCLE_CMD_SEND_LEFT,0));
    }
    sp.Sync (&send, &recv);
    int cleaned = 0;
    //    cleaned = sp.Clean ();

    DBG_INFO ("1: Send: "<<send<<"; Recv: "<<recv<<"; Cleaned: "<<cleaned);

    send = 0; recv = 0;
    sp.Sync (&send, &recv);
    DBG_INFO ("2: Send: "<<send<<"; Recv: "<<recv<<"; Cleaned: "<<cleaned);

    // CommandIterator it = sp.GetCommandIterator (PCLE_CMD_TRACE);
    // while (it.HasNext ())
    // {
    //   PcleCommandInfo &info = it.Next (true);
    //   DBG_INFO ("Trace "<<info.pid);
    // };

    Mpi::Finalize ();
  }
}
