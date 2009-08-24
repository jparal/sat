/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   arms.h
 * @brief  Adaptive rejection Metropolis sampling
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_RAND_ARMS_H__
#define __SAT_RAND_ARMS_H__

#include "stdlib.h"
#include "stdio.h"
#include "rndgen.h"
#include "math/func/stdmath.h"

/// @addtogroup math_rand
/// @{

/**
 * @brief Adaptive rejection metropolis sampling
 * @sa @ref rng_arms
 * @remarks Be very careful how well do you scale the distribution function!
 *          If the maximum is small compared to the zero regions then this
 *          algorithm will generate values even at those regions.
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */
class ARMSRandGen : public RandomGen<double>
{
public:
  typedef RandomGen<double> TRandomGen;

  /// Constructor
  ARMSRandGen ();
  /// Destructor
  ~ARMSRandGen ();

  /**
   * @brief Evaluate distribution function you want to sample.
   * @sa Remark in the class description
   *
   * @param x evaluate at this point
   * @return evaluated value
   */
  virtual double EvalDF (double x) = 0;

  /// to display envelope - for debugging only
  void DbgPrintEnvelope ();

  int GetError () const
  { return _err; }

  // @param neval on exit, the number of function evaluations performed
  int GetNumEval () const
  { return _env_neval; };

  double GetConvex () const
  { return _env_convex; }

  /// Return number from the distribution defined by EvalDF() function
  virtual double Get ();

  /// adaptive rejection metropolis sampling - simplified argument list

  /**
   * @brief Initialization Adaptive Rejection Metropolis Sampling with simplified
   *        argument list.
   * Parameter @p dometrop specify if Metropolis step is required (i.e. the
   * log-density is convex).
   *
   * @param xl left bound
   * @param xr right bound
   * @param dometrop whether metropolis step is required
   */
  void Initialize (double xl, double xr, bool dometrop);

  /**
   * @brief Initialization Adaptive Rejection Metropolis Sampling.
   * Parameter @p dometrop specify if Metropolis step is required (i.e. the
   * log-density is convex). Parameter @p npoint should be at least
   * (2*ninit+1).
   *
   * @param xinit initial x-values
   * @param ninit umber of initial x-values
   * @param xl left bound
   * @param xr right bound
   * @param convex adjustment for convexity
   * @param npoint maximum number of points allowed in envelope
   * @param dometrop whether metropolis step is required
   */
  void Initialize (double *xinit, int ninit, double *xl, double *xr,
		   double convex, int npoint, bool dometrop);

private:

  /// a point in the x,y plane
  typedef struct point {
    double x,y;             /**< x and y coordinates */
    double ey;              /**< exp(y-ymax+YCEIL) */
    double cum;             /**< integral up to x of rejection envelope */
    int f;                  /**< is y an evaluated point of log-density */
    struct point *pl,*pr;   /**< envelope points to left and right of x */
  } Point;

  /// @name Envelope
  /// @brief attributes of the entire rejection envelope
  /// @{

  int _env_cpoint;          /**< number of POINTs in current envelope */
  int _env_npoint;          /**< max number of POINTs allowed in envelope */
  int _env_neval;           /**< number of function evaluations performed */
  double _env_ymax;         /**< the maximum y-value in the current envelope */
  Point *_env_p;            /**< start of storage of envelope POINTs */
  double _env_convex;       /**< adjustment for convexity */

  /// @}

  /// @name Metropolis
  /// @brief for metropolis step
  /// @{

  bool _met_on;           /**< whether metropolis is to be used */
  double _met_xprev;      /**< previous Markov chain iterate */
  double _met_yprev;      /**< current log density at xprev */

  /// @}

  int _err;

  /**
   * To sample from piecewise exponential envelope
   *
   * @param p a working POINT to hold the sampled value
   */
  int Sample (Point *p);

  /**
   * to obtain a point corresponding to a qiven cumulative probability
   *
   * @param prob cumulative probability under envelope
   * @param p a working POINT to hold the sampled value
   */
  int Invert (double prob, Point *p);

  /**
   * to perform rejection, squeezing, and metropolis tests
   *
   * @param p point to be tested
   * @return error code
   */
  int Test (Point *p);

  /**
   * to update envelope to incorporate new point on log density
   *
   * @param p point to be incorporated
   * @return error code
   */
  int Update (Point *p);

  /**
   * to exponentiate and integrate envelope
   */
  void Cumulate ();

  /**
   * To find where two chords intersect
   *
   * @param q to store point of intersection
   *
   * @return error code
   */
  int Meet (Point *q);

  /**
   * To integrate piece of exponentiated envelope to left of POINT q
   * @return error code
   */
  double Area (Point *q);

  /// to exponentiate shifted y without underflow
  double ExpShift (double y, double y0);
  /// inverse of function expshift
  double LogShift (double y, double y0);

  /**
   * to evaluate log density and increment count of evaluations
   *
   * @param x point at which to evaluate log density
   * @return error code
   */
  double Perfunc (double x);
};

/// @}

#endif /* __SAT_RAND_ARMS_H__ */
