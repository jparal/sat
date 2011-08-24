/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/02, @jparal}
 * @revmessg{Initial version}
 */

template<class T, int D>
void HermCAMCode<T,D>::PreInitialize (const ConfigFile &cfg)
{
  if (cfg.Exists ("dipole"))
  {
    _dipole = true;
    cfg.GetValue ("dipole.amp", _amp);
    cfg.GetValue ("dipole.rpos", _rpos);
    cfg.GetValue ("dipole.radius", _radius);
    cfg.GetValue ("dipole.bclen", _plbcleni);
    cfg.GetValue ("dipole.vthnorm", _vthplnorm, 0.1);
    _radius2 = _radius * _radius;
    _plbcleni = T(1) / _plbcleni;
  }
  else
  {
    DBG_WARN ("Skipping dipole initialization!");
    _dipole = false;
  }
}

template<class T, int D>
void HermCAMCode<T,D>::PostInitialize (const ConfigFile &cfg)
{
  if (_dipole)
  {
    FldVector xp = 0., mv = 0., b0 = ((TBase*)this)->_B0;
    T r3 = _radius2 * _radius;
    xp[0] = _radius;
    mv[D-1] = _amp;
    if (r3 > M_EPS)
      b0 += ((T)3.*(mv*xp) * xp - mv)/r3;

    DBG_INFO ("Dipole initialization:");
    DBG_INFO ("  amplitude      : "<<_amp);
    DBG_INFO ("  relative pos.  : "<<_rpos);
    DBG_INFO ("  planet radius  : "<< Math::Sqrt(_radius2));
    DBG_INFO ("  B/B0 @ surface : "<< b0.Norm ());

    _maxwplnorm.Initialize (_vthplnorm);
  }
}
