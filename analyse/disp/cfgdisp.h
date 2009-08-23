/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cfgdisp.h
 * @brief  Configuration class of dispersion solver
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CFGDISP_H__
#define __SAT_CFGDISP_H__

#include "satbase.h"

/**
 * @brief Configuration class of dispersion solver
 *
 * @revision{1.1}
 * @reventry{2009/08, @jparal}
 * @revmessg{Initial version}
 */
class ConfigDisp
{
public:
  typedef Array<double> DArray;
  typedef Vector<double,2> DVector2;
  typedef Vector<int,3> IVector3;

  /// Constructor
  ConfigDisp () {};
  /// Destructor
  ~ConfigDisp () {};

  void Initialize (int argc, char **argv);

  const char* Project ()
  { return _prjname.GetData (); }

  const char* CfgName ()
  { return _cfgname.GetData (); }

  const char* OutName ()
  { return _outname.GetData (); }

public:
  String _cfgname;       ///< Input file name
  String _outname;       ///< Project name + h5 suffix
  String _prjname;       ///< Name of the project
  int _units;            ///< Units 0: v_A, w_cp; 1: r_ge and w_ce
  double _rwpewce;       ///< Ratio of el. plasma freq. to el. cyclotron freq.
  double _rmemp;         ///< Ratio of me/mp (comment for real value)
  IVector3 _nterms;      ///< Number of terms in the sum (comment for -inf,inf)

  DVector2 _kvec;        ///< k vectors: k min, k max
  int _ksamp;            ///< number of samples of k vector

  DVector2 _theta;       ///< theta=angle(k,b0): min, max
  int _tsamp;            ///< number of samples of thera angle

  DVector2 _omega;       ///< domain of interest - omega_min, omega_max
  DVector2 _gamma;       ///< domain of interest - gamma_min, gamma_max
  double _error;         ///< Permissible err. (diff. btw. polarisa. of 2 sucs)

  int _nsp;              ///< Number of species
  DArray _mass;          ///< Masses (unit=proton mass); 0.-elect.
  DArray _charge;        ///< Charges of spec.(in units of proton charge e)
  DArray _rdn;           ///< Relative densities (plasma should be neutral)
  DArray _beta;          ///< Beta parallel of spec
  DArray _ani;           ///< Temperature anisotropy: Tper/Tpar
  DArray _vpar;          ///< Parallel vel. (electrons are forced in rest)
  DArray _vper;          ///< Perpendicular vel. (only non-magnetized approx.)
};

#endif /* __SAT_CFGDISP_H__ */
