/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   kenergy.h
 * @brief  Kinetic energy of particles.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/11, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_KENERGY_H__
#define __SAT_KENERGY_H__

#include "sensor.h"
#include "simul/pcle/camspecie.h"
#include "satio.h"

/// @addtogroup simul_sensor
/// @{

/**
 * @brief Kinetic energy of particles.
 *
 * In fact the sensor should store the density of the article kinetic energy
 * defined on the mesh in the center of the cell (B-mesh) defined as:
 * @f[
 * w_{s} = \frac{1}{2}m_s \int v^2 f(x,v) \rm{dv}
 * @f]
 * where s refer to specie, m is mass in proton mass @$ m_i @$; and f is
 * distribution function.
 *
 * @revision{1.0}
 * @reventry{2009/01, @jparal}
 * @revmessg{Initial version}
 */
template<class T, int R, int D>
class KineticEnergySensor : public Sensor
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
		   Field<Vector<T,R>,D> *B)
  {
    Sensor::Initialize (cfg, id);
    _specie = specie;
    _B = B;
  }

  virtual bool SupportPerPar () const
  { return true; }

  virtual void SaveData (IOManager &iomng, const SimulTime &stime)
  {
    Mesh<D> bmesh = _B->GetMesh();
    Mesh<D> mesh (bmesh);
    mesh.Cells () += 2;
    Layout<D> blayout = _B->GetLayout();
    Layout<D> layout;
    //                  GHOSTS:     SHARE:       BC: DECOMPOSITION:
    layout.Initialize (Loc<D> (1), Loc<D> (1), blayout.GetOpen(), blayout.GetDecomp());

    _kent.Initialize (mesh, layout);
    _kens.Initialize (mesh, layout);
    _kent = (T)0;

    for (int i=0; i<_specie->GetSize (); ++i)
    {
      TSpecie *sp = _specie->Get (i);
      CalcKEnergy (*sp, _kens);

      if (_specie->GetSize () > 1)
	iomng.Write (_kens, stime, GetTag (i));

      _kent += _kens;
    }

    iomng.Write (_kent, stime, GetTag ());

    _kent.Free ();
    _kens.Free ();
  }

private:
  void CalcKEnergy (const TSpecie &sp, Field<Vector<T,2>,D>& ken)
  {
    ken = (T)0;

    VelVector v;
    FldVector bp;
    PerParVector v2;
    T vpar2, vper2;

    BilinearWeightCache<T,D> cache;
    size_t npcle = sp.GetSize ();
    for (int pid=0; pid<npcle; ++pid)
    {
      const TParticle &pcle = sp.Get (pid);

      v = pcle.vel;
      FillCache (pcle.pos, cache);
      cache.ipos += 1; // we have one ghost!!!
      CartStencil::BilinearWeight (*_B, cache, bp);

      bp = v >> bp.Unit ();
      v2[1] = bp.Norm2 ();              // v_par^2
      v2[0] = v.SquaredNorm () - v2[1]; // v_per^2

      CartStencil::BilinearWeightAdd (ken, cache, v2);
    }

    ken.Sync ();
    ken *= 0.5 * sp.MassPerPcle ();
  };

  Field<Vector<T,2>,D> _kens;
  Field<Vector<T,2>,D> _kent;
  Field<Vector<T,R>,D> *_B;
  RefArray<TSpecie> *_specie;
};

/// @}

#endif /* __SAT_KENERGY_H__ */
