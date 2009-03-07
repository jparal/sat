/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/12, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T>
MonteCarloCode<B,T>::MonteCarloCode () {}

template<class B, class T>
MonteCarloCode<B,T>::~MonteCarloCode ()
{
  DBG_INFO ("cleaning MonteCarloCode ...");
  plog.flush ();
}

template<class B, class T>
void MonteCarloCode<B,T>::Initialize (int *pargc, char ***pargv)
{
  Code::Initialize (pargc, pargv, true);

  /******************/
  /* Section: SIMUL */
  /******************/
  _time.Initialize (GetCfgFile(), 0);

  /*****************/
  /* Section: MISC */
  /*****************/
  Vector<int,D> ratio;

  GetCfgFile().GetValue ("parallel.mpi.proc", ratio);
  DBG_INFO1 ("MPI decomposition ratio: "<<ratio);

  _mesh.Initialize (GetCfgFile().GetEntry ("grid"));
  _decomp.Initialize (ratio, Mpi::COMM_WORLD);
  DBG_INFO1 ("decomposing mesh (cells): "<<_mesh.Dim ());
  _decomp.Decompose (_mesh.Dim ());
  DBG_INFO1 ("mesh decomposed into (cells) => "<<_mesh.Dim ());
  //                  GHOSTS:       SHARE:   OpenBC: DECOMPOS:
  _layout.Initialize (Loc<D> (1), Loc<D> (0), false, _decomp);

  _E.Initialize (_mesh, _layout);
  _B.Initialize (_mesh, _layout);

  // TSpecie *_ions = new Specie<T,D> ();
  // _ions->Initialize (species[i], _mesh, _layout);
  // TSpecie *_neutrals = new Specie<T,D> ();
  // _neutrals->Initialize (species[i], _mesh, _layout);

  /*********************/
  /* Setup all sensors */
  /*********************/
  _sensmng.Initialize (GetCfgFile());
}
