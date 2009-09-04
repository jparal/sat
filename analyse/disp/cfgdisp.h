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
  typedef Array<int> IArray;
  typedef Vector<double,2> DVector2;
  typedef Vector<int,3> IVector3;

  /// Constructor
  ConfigDisp () {};
  /// Destructor
  ~ConfigDisp () {};

  void Initialize (int argc, char **argv);

  const char* Project () const { return _prjname.GetData (); }
  const char* CfgName () const { return _cfgname.GetData (); }
  const char* OutName () const { return Project (); }

  double Rwpewce () const { return _rwpewce; }

  double KMin () const { return _kvec[0]; }
  double KMax () const { return _kvec[1]; }
  int KSamp ()   const { return _ksamp; }
  double GetKSample (int i) const;

  double ThetaMin () const { return _theta[0]; }
  double ThetaMax () const { return _theta[1]; }
  int ThetaSamp ()   const { return _tsamp; }

  double OmegaMin () const { return _omega[0]; }
  double OmegaMax () const { return _omega[1]; }

  double GammaMin () const { return _gamma[0]; }
  double GammaMax () const { return _gamma[1]; }

  int Nspecie ()         const { return _nsp; }
  int Mass (int sp)      const { return _mass[sp]; }
  int Charge (int sp)    const { return _charge[sp]; }
  double RelDn (int sp)  const { return _rdn[sp]; }
  double Beta (int sp)   const { return _beta[sp]; }
  double Ani (int sp)    const { return _ani[sp]; }
  double V0Par (int sp)  const { return _vpar[sp]; }
  double V0Per (int sp)  const { return _vper[sp]; }
  double VthPar (int sp) const;
  double VthPer (int sp) const;
  double PlasmaFreq (int sp) const; ///< Plasma frequency
  double CycloFreq (int sp)  const; ///< Cyclotron frequency

private:
  String _cfgname;       ///< Input file name
  String _prjname;       ///< Name of the project
  int _units;            ///< Units 0: v_A, w_cp; 1: r_ge and w_ce
  double _rwpewce;       ///< Ratio of el. plasma freq. to el. cyclotron freq.
  double _rmemp;         ///< Ratio of me/mp (comment for real value)
  //IVector3 _nterms;      ///< Number of terms in the sum (comment for -inf,inf)

  DVector2 _kvec;        ///< k vectors: k min, k max
  int _ksamp;            ///< number of samples of k vector

  DVector2 _theta;       ///< theta=angle(k,b0): min, max
  int _tsamp;            ///< number of samples of thera angle

  DVector2 _omega;       ///< domain of interest - omega_min, omega_max
  DVector2 _gamma;       ///< domain of interest - gamma_min, gamma_max
  double _error;         ///< Permissible err. (diff. btw. polarisa. of 2 sucs)

  int _nsp;              ///< Number of species
  IArray _mass;          ///< Masses (unit=proton mass); 0.-elect.
  IArray _charge;        ///< Charges of spec.(in units of proton charge e)
  DArray _rdn;           ///< Relative densities (plasma should be neutral)
  DArray _beta;          ///< Beta parallel of spec
  DArray _ani;           ///< Temperature anisotropy: Tper/Tpar
  DArray _vpar;          ///< Parallel vel. (electrons are forced in rest)
  DArray _vper;          ///< Perpendicular vel. (only non-magnetized approx.)
};

#endif /* __SAT_CFGDISP_H__ */
