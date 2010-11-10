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
void InstabilityCAMCode<T,D>::PreInitialize (const ConfigFile &cfg)
{
  if (cfg.Exists ("wave"))
  {
    _wave = true;
    cfg.GetValue ("wave.mode", _mode, "saw");
    cfg.GetValue ("wave.nperiod", _npex);
    cfg.GetValue ("wave.amp", _amp);
    cfg.GetValue ("wave.angle", _angle, 0.);
    _angle = Math::Deg2Rad (_angle);
  }
  else
  {
    DBG_WARN ("Skipping wave initialization!");
    _wave = false;
  }

  if (cfg.Exists ("anisotropy"))
  {
    _anisotropy = true;
    cfg.GetValue ("anisotropy.amp", _aamp, 1.);
    cfg.GetValue ("anisotropy.width", _awidth, 1.);
    cfg.GetValue ("anisotropy.rx", _arx, .5);
  }
  else
  {
    DBG_WARN ("Skipping anisotropy initialization!");
    _anisotropy = false;
  }
}

template<class T, int D>
void InstabilityCAMCode<T,D>::PostInitialize (const ConfigFile &cfg)
{
  if (_wave)
  {

    if (Math::Abs(TBase::_phi) > M_EPS || Math::Abs(TBase::_psi) > M_EPS)
      DBG_WARN ("we expect B0 to be parallel to X-axis");

    Vector<T,D> l, k;
    VecField &U = this->_U;

    for (int i=0; i<D; ++i)
    {
      int nc = U.Size (i)-1;
      int gh = U.GetLayout ().GetGhost (i);
      int np = U.GetLayout ().GetDecomp ().GetSize (i);
      T dx = U.GetMesh ().GetResol (i);
      _k[i] = (M_2PI * (T)_npex[i]) / ((T)((nc - 2*gh) * np));

      k[i] = _k[i] / dx;
      l[i] = M_2PI/k[i];
    }

    DBG_INFO ("Wave initialization:");
    DBG_INFO ("  mode             : "<<_mode);
    DBG_INFO ("  nperiod          : "<<_npex);
    DBG_INFO ("  angle(k,x) [deg] : "<< Math::Rad2Deg(_angle));
    DBG_INFO ("  amp/B0           : "<<_amp);
    DBG_INFO ("  kc/wp            : "<< k);
    DBG_INFO ("  lambda [c/w_p]   : "<< l);

  } // if (_wave)

  if (_anisotropy)
  {
    VecField &B = this->_B;
    int nc = B.Size (0)-1;
    int np = B.GetLayout ().GetDecomp ().GetSize (0);
    T dx = B.GetMesh ().GetResol (0);
    _acx = T(0);
    _acx[0] = _arx * dx * T(nc*np);

    DBG_INFO ("Anisotropy initialization:");
    DBG_INFO ("  amplitude : "<<_aamp);
    DBG_INFO ("  width     : "<<_awidth);
    DBG_INFO ("  rel. pos. : "<<_arx);

  } // if (_anisotropy)
}
