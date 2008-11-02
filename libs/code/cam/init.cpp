/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
CAMCode<B,T,D>::CAMCode () {}

template<class B, class T, int D>
CAMCode<B,T,D>::~CAMCode ()
{
  DBG_INFO ("cleaning CAMCode ...");
  plog.flush ();
}

template<class B, class T, int D>
void CAMCode<B,T,D>::Initialize (int *pargc, char ***pargv)
{
  Mpi::Initialize (pargc, pargv);
  int argc = *pargc;
  char **argv = *pargv;

  _exename = argv[0];
  _logname = _exename;
  _logname += ".log";
  _cfgname = _exename;
  _cfgname += ".sin";

  // TODO: temporarily
  if (argc == 2) _cfgname = argv[1];

  // Handle all parameters
  for (int i=1; i<argc; ++i)
  {
  }

  char cproc[6];
  snprintf (cproc, 6, "%.3d> ", Mpi::Rank ());
  DBG_PREFIX (cproc);
  DBG_ENABLE (Mpi::Rank () == 0);

  DBG_INFO (PACKAGE_NAME" v"PACKAGE_VERSION);
  DBG_INFO ("architecture: "PLATFORM_NAME"/"PLATFORM_OS_NAME" v"<<
	    PLATFORM_OS_VERSION<< "/"PLATFORM_PROCESSOR_NAME);
  DBG_INFO ("compiler: "_STRINGIFY(PLATFORM_COMPILER_FAMILYNAME)"/v"
	    PLATFORM_COMPILER_VERSION_STR);
  DBG_INFO ("configured on: "CONFIGURE_DATE);
  DBG_INFO (PACKAGE_COPYRIGHT);
  DBG_INFO ("Report bugs to <"PACKAGE_BUGREPORT">");
  DBG_INFO ("CAM-CL simulation code");

  const char *file = _cfgname.GetData ();
  DBG_INFO1 ("reading configuration file: "<<file);
  try
  {
    _cfg.ReadFile (file);
    _cfg.SetAutoConvert ();
  }
  catch (ParseException &ex)
  {
    SAT_ABBORT (file<<"(" << ex.GetLine() << "): Parsing error: " <<
		ex.GetError() << endl);
  }
  catch (FileIOException &ex)
  {
    SAT_ABBORT ("Parsing file: '"<<file<<"'");
  }

  PreInitialize (_cfg);
  Initialize ();
  PostInitialize (_cfg);

  // Update parameters based on the command line parameters
}

template<class B, class T, int D>
void CAMCode<B,T,D>::Initialize ()
{
  int ver[3];
  if (_cfg.Exists ("sat.version"))
  {
    ConfigEntry &ent = _cfg.GetEntry ("sat.version");
    int len = ent.GetLength ();
    if (len>=1) ver[0] = ent[0]; else ver[0] = 0;
    if (len>=2) ver[1] = ent[1]; else ver[1] = 0;
    if (len>=3) ver[2] = ent[2]; else ver[2] = 0;
  }
  else
  {
    ver[0] = 0; ver[1] = 3; ver[2] = 0;
  }
  _ver = SAT_VERSION_MAKE (ver[0], ver[1], ver[2]);
  DBG_INFO1 ("assuming config version: v"<<
	     ver[0]<<"."<<ver[1]<<"."<<ver[2]);

  /******************/
  /* Section: SIMUL */
  /******************/
  _time.Initialize (_cfg.GetEntry ("simul"), _ver);
  _cfg.GetValue ("simul.momsmooth", _momsmooth, 1);
  _cfg.GetValue ("simul.esmooth", _esmooth, 1);
  DBG_INFO1 ("moment/electric Field smoothing: "<<
	     _momsmooth<<", "<<_esmooth);

  /*****************/
  /* Section: MISC */
  /*****************/
  Mesh<D> mesh;
  Vector<int,D> ratio;
  Vector<bool,D> openbc;

  _cfg.GetValue ("parallel.mpi.proc", ratio);
  _cfg.GetValue ("grid.openbc", openbc);
  DBG_INFO1 ("MPI decomposition ratio: "<<ratio);
  DBG_INFO1 ("open Boundary conditions: "<<openbc);

  mesh.Initialize (_cfg.GetEntry ("grid"));
  _decomp.Initialize (ratio, Mpi::COMM_WORLD);
  DBG_INFO1 ("decomposing mesh (cells): "<<mesh.Dim ());
  _decomp.Decompose (mesh.Dim ());
  DBG_INFO1 ("mesh decomposed into (cells) => "<<mesh.Dim ());

  // Variable:  # grid points  # ghosts  # share   # total    Centring
  // =================================================================
  //    E         #cells           1         0    #cells + 2    Cell
  //    B         #cells + 1       0         0    #cells + 1    Node
  //    U         #cells + 1       1         1    #cells + 3    Node
  //    dn        #cells + 1       1         1    #cells + 3    Node
  //    Particles #cells           0         0    #cells + 1    Node
  //
  // Note that dn and U needs extra 1 grid points of both side (even when is
  // defined on the same grid like B) just to have a space for boundary
  // conditions. The idea is to use Sync mechanism in Field class to copy 1
  // layer of ghost zone and in boundary conditions treatment just add the
  // ghost values to the outer values.

  _meshe = mesh; _meshb = mesh; _meshu = mesh; _meshp = mesh;

  _meshe.Dim () += 2; _meshe.Center () = Cell;
  _meshb.Dim () += 1; _meshb.Center () = Node;
  _meshu.Dim () += 3; _meshu.Center () = Node;
  _meshp.Dim () += 1; _meshp.Center () = Node;

  //                  GHOSTS:     SHARE:       BC: DECOMPOSITION:
  _layoe.Initialize (Loc<D> (1), Loc<D> (0), openbc, _decomp);
  _layob.Initialize (Loc<D> (0), Loc<D> (0), openbc, _decomp);
  _layou.Initialize (Loc<D> (1), Loc<D> (1), openbc, _decomp);
  _layop.Initialize (Loc<D> (0), Loc<D> (0), openbc, _decomp);

  /*******************/
  /* Section: SECIES */
  /*******************/
  _cfg.GetValue ("plasma.betae", _betae);
  ConfigEntry &species = _cfg.GetEntry ("plasma.specie");
  for (int i=0; i<species.GetLength (); ++i)
  {
    DBG_INFO1 ("processing specie: '"<<species[i].GetName ()<<"'");
    TSpecie *sp = new Specie<T,D> ();
    sp->Initialize (species[i], _meshp, _layop);
    _specie.PushNew (sp);
  }

  // Minimal/Maximal position of the particle:
  _pmin = PosVector ((T)0.0);
  _pmax = mesh.Dim ();
  DBG_INFO1 ("pmin, pmax: " << _pmin<< "; "<<_pmax);

  /******************/
  /* Section: FIELD */
  /******************/
  _cfg.GetValue ("field.nsub", _nsub, 10);
  _cfg.GetValue ("field.imf.phi", _phi, 90.);
  _cfg.GetValue ("field.imf.psi", _psi, 0.);
  _cfg.GetValue ("field.dnmin", _dnmin, 0.05);
  _cfg.GetValue ("field.resist", _resist, 0.001);
  DBG_INFO1 ("magnetic field sub-steps: "<<_nsub);
  DBG_INFO1 ("IMF phi, psi: "<<_phi<<", "<<_psi);
  DBG_INFO1 ("minimal density: "<<_dnmin);
  DBG_INFO1 ("resistivity: "<<_resist);

  /****************/
  /* Section: LOG */
  /****************/
  String logname = _logname;
  _cfg.GetValue ("output.logfile", _logname, logname);

  /************************************/
  /* Setup initial magnetic field _B0 */
  /************************************/
  _phi = (M_PI / 180.0) * _phi;
  _psi = (M_PI / 180.0) * _psi;
  _B0[0] = Math::Cos (_phi) * Math::Cos (_psi);
  _B0[1] = Math::Sin (_phi) * Math::Cos (_psi);
  _B0[2] = Math::Sin (_psi);
  DBG_INFO1 ("background magnetic field: "<<_B0);

  /*****************************************************************/
  /* Setup plasma bulk velocity _v0 and initial electric field _E0 */
  /*****************************************************************/
  _v0 = 0.;
  double dnt = 0., dns = 0.;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    dns = sp->RelMassDens () * sp->ChargeMassRatio ();
    _v0 += sp->InitalVel () * dns;
    dnt += dns;
  }
  _v0 /= dnt;
  _E0 = - (_v0 % _B0);
  DBG_INFO1 ("total bulk velocity: "<<_v0);
  DBG_INFO1 ("background electric field: "<<_E0);

  /***********************************/
  /* Setup the rest of the variables */
  /***********************************/
  _gamma = 5. / 3.;

  _betai = 0.;
  double cd = 0.;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    _betai += sp->Beta ();
    cd += sp->ChargeMassRatio () * sp->RelMassDens ();
  }
  _te = _betae / (2. * cd);

  DBG_INFO1 ("total ion beta: "<<_betai);
  DBG_INFO1 ("electron temperature: "<<_te);

  /****************************/
  /* Setup mesh related stuff */
  /****************************/
  _E.Initialize (_meshe, _layoe);

  _B.Initialize (_meshb, _layob);
  _Bh.Initialize (_meshb, _layob);

  _pe.Initialize (_meshu, _layou);
  _dn.Initialize (_meshu, _layou);
  _dna.Initialize (_meshu, _layou);
  _dnf.Initialize (_meshu, _layou);
  _U.Initialize (_meshu, _layou);
  _Ua.Initialize (_meshu, _layou);
  _Uf.Initialize (_meshu, _layou);

  _B = _B0; // _Bh is initialized in function First()
  static_cast<B*>(this)->BInitAdd (_B);

  /*********************/
  /* Setup all sensors */
  /*********************/
  _sensmng.Initialize (_cfg);

  ScaFieldSensor<T,D> *nsens = new ScaFieldSensor<T,D>;
  VecFieldSensor<T,3,D> *bsens = new VecFieldSensor<T,3,D>;
  VecFieldSensor<T,3,D> *esens = new VecFieldSensor<T,3,D>;
  VecFieldSensor<T,3,D> *usens = new VecFieldSensor<T,3,D>;
  DistFncSensor<T,D> *dfsens = new DistFncSensor<T,D>;

  nsens->Initialize (&_dn, "density", _cfg);
  esens->Initialize (&_E, "elfield", _cfg);
  bsens->Initialize (&_B, "magfield", _cfg);
  usens->Initialize (&_U, "velocity", _cfg);
  dfsens->Initialize (&_specie, &_B, "distfnc", _cfg);

  _sensmng.AddSensor (nsens);
  _sensmng.AddSensor (bsens);
  _sensmng.AddSensor (esens);
  _sensmng.AddSensor (usens);
  _sensmng.AddSensor (dfsens);

  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);

    _dn = 1.;
    _U = _v0;
    static_cast<B*>(this)->DnInitAdd (sp, _dn);
    static_cast<B*>(this)->BulkInitAdd (sp, _U);
    sp->LoadPcles (_dn, _U, _B0);
  }

  DBG_INFO ("CAMCode::Initialize done!");
}
