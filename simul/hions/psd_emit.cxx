/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   psd_emit.cxx
 * @brief  Photo-stimulated desorption (PSD) sphere emitter.
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "psd_emit.h"
#include "utils.h"

template<class T>
void PSDSphereEmitter<T>::InitializeLocal (ConfigEntry &cfg,
                                  const SIHybridUnitsConvert<T> &si2hyb,
					   Field<T,2> &src)
{
  T mass;
  _si2hyb = si2hyb;
  cfg.GetValue ("ubind", _ubind);
  cfg.GetValue ("xpar", _xpar);
  cfg.GetValue ("mass", mass);

  DBG_INFO ("  binding energy U [eV]:      "<<_ubind);
  DBG_INFO ("  parameter x of DF:          "<<_xpar);
  DBG_INFO ("  mass of the particle:       "<< mass);
  this->SetMass (mass);

  _conv = (2.*M_PHYS_E)/(mass*M_PHYS_MI);
  _psddf.Initialize (_ubind, _xpar);

  T lon, lat, coslon, coslat;
  T dlon = M_2PI / (T)src.GetSize(0);
  T dlat = M_PI / (T)src.GetSize(1);
  for (int i=0; i<src.GetSize(0); i++)
  {
    lon = ((T)i + 0.5) * dlon;
    for (int j=0; j<src.GetSize(1); j++)
    {
      lat = M_PI_2 - ((T)j + 0.5) * dlat;
      if (lon > M_PI_2 && lon < 1.5 * M_PI)
      {
	coslon = Math::Cos (lon);
	coslat = Math::Cos (lat);
        src (i,j) = -coslon * coslat * coslat;
      }
    }
  }

  // HDF5File file;
  // file.Initialize (false, 6, true);
  // file.Write (src, Cell, "PSD", "PSDmap");
}

template class PSDSphereEmitter<float>;
template class PSDSphereEmitter<double>;
