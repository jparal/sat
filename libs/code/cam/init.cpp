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
void CAMCode<B,T,D>::Initialize (int *pargc, char ***pargv)
{
  Code::Initialize (pargc, pargv, true, false);

  DBG_INFO ("=========== PreInitialize: ==========");
  PreInitialize (Code::GetCfgFile ());
  DBG_INFO ("=========== Initialize: =============");
  Initialize ();
  DBG_INFO ("=====================================");
}

template<class B, class T, int D>
void CAMCode<B,T,D>::Initialize ()
{
  ConfigFile  &cfg = Code::GetCfgFile ();
  satversion_t ver = Code::GetCfgVersion ();

  /******************/
  /* Section: SIMUL */
  /******************/
  _time.Initialize (cfg.GetEntry ("simul"), ver);
  cfg.GetValue ("simul.momsmooth", _momsmooth, 1);
  cfg.GetValue ("simul.esmooth", _esmooth, 1);
  DBG_INFO ("moment/electric Field smoothing: "<<
	    _momsmooth<<", "<<_esmooth);

  /*****************/
  /* Section: MISC */
  /*****************/
  Mesh<D> mesh;
  Vector<int,D> ratio;
  Vector<bool,D> openbc;

  cfg.GetValue ("parallel.mpi.proc", ratio);
  cfg.GetValue ("grid.openbc", openbc);

  mesh.Initialize (cfg.GetEntry ("grid"));
  _decomp.Initialize (ratio, Mpi::COMM_WORLD);

  DBG_INFO ("MPI decomposition ratio  : "<<_decomp.Size ());
  DBG_INFO ("open Boundary conditions : "<<openbc);

  for (int i=0; i<D; ++i)
    while (mesh.Cells()[i] % _decomp.Size()[i] != 0)
      mesh.Cells()[i]++;

  DBG_INFO ("total number of cells    : "<<mesh.Cells ());
  DBG_INFO ("   X spatial resolution  : "<<mesh.Resol ());
  DBG_INFO ("   = physical size       : "<<mesh.Size ());
  _decomp.Decompose (mesh.Cells ());
  DBG_INFO ("Per single CPU:");
  DBG_INFO ("total number of cells    : "<<mesh.Cells ());
  DBG_INFO ("   X spatial resolution  : "<<mesh.Resol ());
  DBG_INFO ("   = physical size       : "<<mesh.Size ());

  // Minimal/Maximal position of the particle:
  _pmin = PosVector ((T)0.0);
  _pmax = mesh.Cells ();
  DBG_INFO2 ("pmin; pmax               : " << _pmin<< "; "<<_pmax);

  // Variable:  # grid points  # ghosts  # share   # total    Centring
  // =================================================================
  //    E         #cells           1         0    #cells + 2    Cell
  //    B         #cells + 1       0         0    #cells + 1    Node
  //    U         #cells + 1       1         1    #cells + 3    Node
  //    dn        #cells + 1       1         1    #cells + 3    Node
  //    Particles #cells           0         0    #cells + 1    Node
  //
  // Note that dn and U needs extra 1 grid points on both sides (even though
  // they are defined on the same grid like B) just to have a space for
  // boundary conditions. The idea is to use Sync mechanism in Field class to
  // copy 1 layer of ghost zone and in boundary conditions treatment just add
  // the ghost values to the outer values.

  _meshe = mesh; _meshb = mesh; _meshu = mesh; _meshp = mesh;

  _meshe.Cells () += 2; _meshe.Center () = Cell;
  _meshb.Cells () += 1; _meshb.Center () = Node;
  _meshu.Cells () += 3; _meshu.Center () = Node;
  _meshp.Cells () += 1; _meshp.Center () = Node;

  //                  GHOSTS:     SHARE:       BC: DECOMPOSITION:
  _layoe.Initialize (Loc<D> (1), Loc<D> (0), openbc, _decomp);
  _layob.Initialize (Loc<D> (0), Loc<D> (0), openbc, _decomp);
  _layou.Initialize (Loc<D> (1), Loc<D> (1), openbc, _decomp);
  _layop.Initialize (Loc<D> (0), Loc<D> (0), openbc, _decomp);

  /********************/
  /* Section: SPECIES */
  /********************/
  DBG_INFO ("============== Species: =============");
  T rmdstot = 0.0;
  Vector<T,3> currtot = 0.0;

  cfg.GetValue ("plasma.betae", _betae);
  cfg.GetValue ("plasma.vmax", _vmax, -1.);
  DBG_INFO ("max velocity of pcles : "<<_vmax);

  ConfigEntry &species = cfg.GetEntry ("plasma.specie");
  for (int i=0; i<species.GetLength (); ++i)
  {
    DBG_INFO ("processing specie: '"<<species[i].GetName ()<<"'");
    TSpecie *sp = new CamSpecie<T,D> ();
    sp->Initialize (species[i], _meshp, _layop);
    _specie.PushNew (sp);
    // Just the health check
    rmdstot += sp->RelMassDens ();
    currtot += sp->RelMassDens () * sp->InitalVel ();
  }

  SAT_ASSERT_MSG( Math::Abs( rmdstot-1.0 ) < M_MEPS,
                  "Sum of relative mass densities has to be zero!");
  if (Math::Abs( currtot.Abs() ) > M_MEPS)
    DBG_WARN ("Total current is non-zero: "<<currtot);

  /******************/
  /* Section: FIELD */
  /******************/
  DBG_INFO ("=============== Fields: =============");
  cfg.GetValue ("field.nsub", _nsub, 10);
  cfg.GetValue ("field.imf.phi", _phi, 90.);
  cfg.GetValue ("field.imf.psi", _psi, 0.);
  cfg.GetValue ("field.imf.amp", _bamp, 1.);
  cfg.GetValue ("field.dnmin", _dnmin, 0.05);
  cfg.GetValue ("field.resist", _resist, 0.001);
  cfg.GetValue ("field.viscos", _viscos, 0.0);
  DBG_INFO ("B field sub-steps          : "<<_nsub);
  DBG_INFO ("IMF phi(x,y); psi(x,z)     : "<<_phi<<"; "<<_psi);
  DBG_INFO ("minimal density            : "<<_dnmin);
  DBG_INFO ("resistivity                : "<<_resist);
  DBG_INFO ("viscosity                  : "<<_viscos);

  /************************************/
  /* Setup initial magnetic field _B0 */
  /************************************/
  Vector<T,3> b0;
  _phi = Math::Deg2Rad (_phi);
  _psi = Math::Deg2Rad (_psi);
  b0[0] = Math::Cos(_phi) * Math::Cos(_psi);
  b0[1] = Math::Sin(_phi) * Math::Cos(_psi);
  b0[2] = Math::Sin(_psi);
  _B0 = b0 *_bamp;
  DBG_INFO ("background B field (B_0)   : "<<_B0);

  /*****************************************************************/
  /* Setup plasma bulk velocity _v0 and initial electric field _E0 */
  /*****************************************************************/
  _v0 = 0.;
  T dnt = 0., dns = 0.;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    dns = sp->RelMassDens () * sp->ChargeMassRatio ();
    _v0 += sp->InitalVel () * (T)dns;
    dnt += dns;
  }
  _v0 /= dnt;
  _E0 = - (_v0 % _B0);
  DBG_INFO ("background E field (E_0)   : "<<_E0);
  DBG_INFO ("total bulk velocity (u_i)  : "<<_v0);

  /***********************************/
  /* Setup the rest of the variables */
  /***********************************/
  _gamma = 5. / 3.;

  _betai = 0.;
  T cd = 0.;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);
    _betai += sp->Beta ();
    cd += sp->ChargeMassRatio () * sp->RelMassDens ();
  }
  _te = _betae / (2. * cd);
  _cs = Math::Sqrt (0.5 * (_betai + _betae));

  DBG_INFO ("total ion beta (beta_i)    : "<<_betai);
  DBG_INFO ("ion temperature (T_i)      : "<<_betai / (2. * cd));
  DBG_INFO ("electron beta (beta_e)     : "<<_betae);
  DBG_INFO ("electron temperature (T_e) : "<<_te);
  DBG_INFO ("sound speed (c_s)          : "<<_cs);

  /****************************/
  /* Setup mesh related stuff */
  /****************************/
  _E.Initialize (_meshe, _layoe);
  _Psi.Initialize (_meshe, _layoe);
  _Psih.Initialize (_meshe, _layoe);

  _B.Initialize (_meshb, _layob);
  _Bh.Initialize (_meshb, _layob);

  _pe.Initialize (_meshu, _layou);
  _dn.Initialize (_meshu, _layou);
  _dna.Initialize (_meshu, _layou);
  _dnf.Initialize (_meshu, _layou);
  _U.Initialize (_meshu, _layou);
  _Ua.Initialize (_meshu, _layou);
  _Uf.Initialize (_meshu, _layou);

  /*********************/
  /* Setup all sensors */
  /*********************/
  DBG_INFO ("=========== Sensors: ================");
  _sensmng.Initialize (cfg);

  ScaFieldSensor<T,D> *nsens = new ScaFieldSensor<T,D>;
  ScaFieldSensor<T,D> *psisens = new ScaFieldSensor<T,D>;
  VecFieldSensor<T,3,D> *bsens = new VecFieldSensor<T,3,D>;
  VecFieldSensor<T,3,D> *esens = new VecFieldSensor<T,3,D>;
  VecFieldSensor<T,3,D> *usens = new VecFieldSensor<T,3,D>;
  DistFncSensor<T,D> *dfsens = new DistFncSensor<T,D>;
  DbDtVecFieldSensor<T,3,D> *dbdtsens = new DbDtVecFieldSensor<T,3,D>;
  JxBSensor<T,3,D> *jxbsens = new JxBSensor<T,3,D>;
  CurlBxBSensor<T,3,D> *cbxbsens = new CurlBxBSensor<T,3,D>;
  KineticEnergySensor<T,3,D> *ken = new KineticEnergySensor<T,3,D>;
  LaplaceSensor<T,3,D> *lap = new LaplaceSensor<T,3,D>;

  nsens->Initialize (cfg, "density", &_dn);
  esens->Initialize (cfg, "elfield", &_E);
  psisens->Initialize (cfg, "psifnc", &_Psi);
  bsens->Initialize (cfg, "magfield", &_B);
  usens->Initialize (cfg, "velocity", &_U);
  dfsens->Initialize (cfg, "distfnc", &_specie, &_B);
  dbdtsens->Initialize (cfg, "dbdt", &_E, &_B);
  jxbsens->Initialize (cfg, "jxb", &_U, &_B, &_dn);
  cbxbsens->Initialize (cfg, "cbxb", &_B, &_dn);
  ken->Initialize (cfg, "kenergy", &_specie, &_B);
  lap->Initialize (cfg, "laplace", &_E);

  _sensmng.AddSensor (nsens);
  _sensmng.AddSensor (bsens);
  _sensmng.AddSensor (esens);
  _sensmng.AddSensor (psisens);
  _sensmng.AddSensor (usens);
  _sensmng.AddSensor (dfsens);
  _sensmng.AddSensor (dbdtsens);
  _sensmng.AddSensor (jxbsens);
  _sensmng.AddSensor (cbxbsens);
  _sensmng.AddSensor (ken);
  _sensmng.AddSensor (lap);

  DBG_INFO ("=========== PostInitialize: =========");
  PostInitialize (cfg);

  _E = _E0;
  //  _Psi = T(0); // initial value for psi function
  //  _Psih = T(0);
  _B = _B0; // _Bh is initialized in function First()
  static_cast<B*>(this)->BInitAdd (_B);

  /*******************/
  /* Species Loading */
  /*******************/
  int totcleaned = 0;
  for (int i=0; i<_specie.GetSize (); ++i)
  {
    TSpecie *sp = _specie.Get (i);

    _dn = 1.;
    _U = sp->InitalVel ();

    // @todo: Review this change.
    // 3.2.2010/jparal: I think it should be initial velocity of specie instead
    // of total velocity of the plasma.
    // _U = _v0;

    static_cast<B*>(this)->DnInitAdd (sp, _dn);
    static_cast<B*>(this)->BulkInitAdd (sp, _U);
    sp->LoadPcles (_dn, _U, b0);

    /// Remove particles based on the problem (for example: inside of the
    /// planet for the dipole problem)
    size_t npcle = sp->GetSize ();
    for (int pid=0; pid<npcle; ++pid)
    {
      TParticle &pcle = sp->Get (pid);
      static_cast<B*>(this)->PcleBCAdd (sp, pid, pcle);
    }
    int cleaned;
    sp->Clean (&cleaned);
    Mpi::SumReduceOne (&cleaned);
    totcleaned += cleaned;
  }

  DBG_INFO ("Particles cleaned during init: " << totcleaned);
}


template<class B, class T, int D>
CAMCode<B,T,D>::CAMCode () {}

template<class B, class T, int D>
CAMCode<B,T,D>::~CAMCode ()
{
  DBG_INFO ("cleaning CAMCode ...");
  Finalize ();
  plog.flush ();
}

template<class B, class T, int D>
void CAMCode<B,T,D>::Finalize ()
{
}
