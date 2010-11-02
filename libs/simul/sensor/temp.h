/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   temp.h
 * @brief  Particle temperature sensor (ie. 3rd moment of distribution function).
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_TEMP_H__
#define __SAT_TEMP_H__

#include "sensor.h"
#include "simul/pcle/camspecie.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Temperature of particles.
 *
 * @revision{1.1}
 * @reventry{2010/10, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class TemperatureSensor : public Sensor
{
public:
  using Sensor::SaveData;
  typedef Particle<T,D> TParticle;
  typedef CamSpecie<T,D> TSpecie;
  typedef Vector<T,R> VelVector;
  typedef Vector<T,R> FldVector;
  typedef Vector<T,2> PerParVector;

  void Initialize (ConfigFile &cfg, const char *id,
		   RefArray<TSpecie> *specie,
		   Field<Vector<T,R>,D> *B,
		   Field<Vector<T,R>,D> *u,
		   Field<T,D> *dn)
  {
    Sensor::Initialize (cfg, id);
    _specie = specie;
    _B = B;
    _u = u;
    _dn = dn;
  }

  virtual bool SupportPerPar () const
  { return true; }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    // Initialize from _dn since density has extra boundary layer for
    // synchronization with neighbor
    _tpar.Initialize (*_dn);
    _tper.Initialize (*_dn);

    int nspec = _specie->GetSize ();
    // Otherwise density and bulk needs to be calculated for each specie
    // separate
    SAT_ASSERT (nspec == 1);

    for (int i=0; i<nspec; ++i)
    {
      TSpecie *sp = _specie->Get (i);
      CalcTemperature (*sp, _tpar, _tper);

      // if (nspec > 1)
      // {
      // 	iomng.Write (_tpar, stime, GetTag (i) + "par");
      // 	iomng.Write (_tper, stime, GetTag (i) + "per");
      // }
      // else
      {
	String tag = GetTag ();
	iomng.Write (_tpar, stime, tag + "par");
	iomng.Write (_tper, stime, tag + "per");
      }
    }

    _tpar.Free ();
    _tper.Free ();
  }

private:
  void CalcTemperature (const TSpecie &sp, Field<T,D>& tpar, Field<T,D>& tper)
  {
    tpar = T(0);
    tper = T(0);

    VelVector vp;
    FldVector bp, up;
    T vpar2, vper2;

    BilinearWeightCache<T,D> cache;
    size_t npcle = sp.GetSize ();
    for (int pid=0; pid<npcle; ++pid)
    {
      const TParticle &pcle = sp.Get (pid);

      vp = pcle.vel;
      FillCache (pcle.pos, cache);
      CartStencil::BilinearWeight (*_B, cache, bp);
      cache.ipos += 1; // we have one ghost!!!
      CartStencil::BilinearWeight (*_u, cache, up);

      bp.Normalize ();
      vp -= up;
      vpar2 = vp * bp;
      vpar2 *= vpar2;
      vper2 = vp.Norm2 () - vpar2;

      // cache.ipos is already shifted
      CartStencil::BilinearWeightAdd (tpar, cache, vpar2);
      CartStencil::BilinearWeightAdd (tper, cache, vper2);
    }

    tpar.Sync ();
    tper.Sync ();

    tpar *= sp.MassPerPcle ();
    tper *= sp.MassPerPcle () / T(2);

    tpar /= *_dn;
    tper /= *_dn;
  };

  Field<T,D> _tpar;
  Field<T,D> _tper;
  Field<Vector<T,R>,D> *_B;
  Field<Vector<T,R>,D> *_u;
  Field<T,D> *_dn;
  RefArray<TSpecie> *_specie;
};

/// @}

#endif /* __SAT_TEMP_H__ */
