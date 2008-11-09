/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   alfven.h
 * @brief  Alfven wave CAM simulation class
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_ALFVEN_CAM_H__
#define __SAT_ALFVEN_CAM_H__

#include "sat.h"

/**
 * @brief Alfven wave CAM simulation class
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int D>
class AlfvenCAMCode : public CAMCode<AlfvenCAMCode<T,D>,T,D>
{
public:
  typedef CAMCode<AlfvenCAMCode<T,D>,T,D> TBase;
  typedef typename TBase::TSpecie TSpecie;
  typedef Particle<T,D> TParticle;
  typedef typename TBase::ScaField ScaField;
  typedef typename TBase::VecField VecField;

  /// Constructor
  AlfvenCAMCode ()
  {
    _file = fopen ("traj.dat", "w");
    // NewMemTrackerModule ();
  };
  /// Destructor
  virtual ~AlfvenCAMCode ()
  {
    fclose (_file);
    //    FreeMemTrackerModule ();
  };

  void PreMove ()
  {
    TSpecie *sp = this->_specie[0];
    size_t npcle = sp->GetSize ();
    const TParticle &pcle = sp->Get (npcle/2);
    for (int i=0; i<D; ++i) fprintf (_file, " %lf", pcle.pos[i]);
    for (int i=0; i<3; ++i) fprintf (_file, " %lf", pcle.vel[i]);
    fprintf (_file, "\n");
    fflush (_file);
  }

  virtual void PreInitialize (const ConfigFile &cfg)
  {
    cfg.GetValue ("alfven.nperiod", _nperiod, 4);
    cfg.GetValue ("alfven.amplitude", _amp, 0.1);
    cfg.GetValue ("alfven.grpvel", _grpvel, 1.0);

    DBG_INFO ("Alfven wave simulation:");
    DBG_INFO ("  nperiod   = "<<_nperiod);
    DBG_INFO ("  amplitude = "<<_amp);
    DBG_INFO ("  grpvel    = "<<_grpvel);
  }

  void BulkInitAdd (TSpecie *sp, VecField &U)
  {
    int nx = U.Size (0)-1;
    int ghostx = U.GetLayout ().GetGhost (0);
    //    T dx = U.GetMesh ().GetSpacing (0);
    int ipx = U.GetLayout ().GetDecomp ().GetPosition (0);
    int npx = U.GetLayout ().GetDecomp ().GetSize (0);
    T kx = (M_2PI * (T)_nperiod) / ((T)((nx - 2*ghostx) * npx));

    Domain<D> dom;
    U.GetDomainAll (dom);
    DomainIterator<D> it (dom);

    while (it.HasNext ())
    {
      T x = (T)(it.GetLoc()[0] + ipx * nx);
      U(it.GetLoc())[1] = - _amp * _grpvel * Math::Sin (kx * x);
      // UNCOMMENT FOR CIRCULARLY POLARIZED
      //U(it.GetLoc())[2] = + _amp * _grpvel * Math::Sin (kx * x);

      it.Next ();
    }
  }

  void BInitAdd (VecField &b)
  {
    int nx = b.Size (0)-1;
    //    T dx = b.GetMesh ().GetSpacing (0);
    int ipx = b.GetLayout ().GetDecomp ().GetPosition (0);
    int npx = b.GetLayout ().GetDecomp ().GetSize (0);
    T kx = (M_2PI * (T)_nperiod) / ((T)(nx * npx));

    Domain<D> dom;
    b.GetDomainAll (dom);
    DomainIterator<D> it (dom);

    while (it.HasNext ())
    {
      T x = (T)(it.GetLoc()[0] + ipx * nx);
      b(it.GetLoc())[1] += _amp * Math::Sin (kx * x);
      // UNCOMMENT FOR CIRCULARLY POLARIZED
      //b(it.GetLoc())[2] -= _amp * Math::Sin (kx * x);

      it.Next ();
    }
  }

private:
  int _nperiod;
  T _amp;
  T _grpvel;
  FILE *_file;
};

#endif /* __SAT_ALFVEN_CAM_H__ */
