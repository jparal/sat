/*
  ChangeLog:

  20.2.2004 : Odstraneni druhe rampy, ktera vznika pri inicializaci simulace.
              Funkce shock_cut_values()
  22.4.2004 : Zmena fitovaciho algoritmu na multifit z GSL

*/

#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_randist.h>
#include <gsl/gsl_vector.h>
#include <gsl/gsl_blas.h>
#include <gsl/gsl_multifit_nlin.h>

#define SHOCK_FRONT_LENGTH 0.05  // % of values
#define SHOCK_FILTER_LENGTH 0.01  // % of values

#define FIT(i) gsl_vector_get(s->x, i)

typedef struct fit_data_ {
  size_t  n;
  double *y;
  double *x;
  double *sigma;
} fit_data;

int
expb_f (const gsl_vector * x, void *params, 
        gsl_vector * f)
{
  size_t n = ((fit_data *)params)->n;
  double *yy = ((fit_data *)params)->y;
  double *xx = ((fit_data *)params)->x;
  double *sigma = ((fit_data *)params)->sigma;

  double A0 = gsl_vector_get (x, 0);
  double CH = gsl_vector_get (x, 1);
  double X0 = gsl_vector_get (x, 2);
  double Y0 = gsl_vector_get (x, 3);

  size_t i;

  for (i = 0; i < n; i++)
    {
      /* Model Yi = A0 * tanh( (x-X0)/CH ) + Y0 */
      double t = xx[i];
	//i * g_dx;
      double Yi = A0 * tanh( (t - X0)/CH ) + Y0;
      gsl_vector_set (f, i, (Yi - yy[i])/sigma[i]);
    }

  return GSL_SUCCESS;
}

int
expb_df (const gsl_vector * x, void *params, 
         gsl_matrix * J)
{
  size_t n = ((fit_data *)params)->n;
  double *sigma = ((fit_data *) params)->sigma;
  double *xx = ((fit_data *)params)->x;

  double A0 = gsl_vector_get (x, 0);
  double CH = gsl_vector_get (x, 1);
  double X0 = gsl_vector_get (x, 2);
  //  double Y0 = gsl_vector_get (x, 3);

  size_t i;

  for (i = 0; i < n; i++)
    {
      /* Jacobian matrix J(i,j) = dfi / dxj, */
      /* where fi = (Yi - yi)/sigma[i],      */
      /*       Yi = A0 * tanh( (x-X0)/CH ) + Y0  */
      /* and the xj are the parameters (A,lambda,b) */
      double t = xx[i];
      //i * g_dx;
      double s = sigma[i];
      double th = tanh( (t - X0) / CH );
      double ch2 = cosh( (t - X0) / CH ) * cosh( (t - X0) / CH );
      gsl_matrix_set (J, i, 0, th / s );
      gsl_matrix_set (J, i, 1, (  -A0 * (t-X0) ) / ( s * CH * CH * ch2 ) );
      gsl_matrix_set (J, i, 2, (   -A0   ) / ( s * CH * ch2 ) );
      gsl_matrix_set (J, i, 3, 1 / s);

    }
  return GSL_SUCCESS;
}

int
expb_fdf (const gsl_vector * x, void *params,
          gsl_vector * f, gsl_matrix * J)
{
  expb_f (x, params, f);
  expb_df (x, params, J);

  return GSL_SUCCESS;
}

#define WINDOW .1

void
shock_fit_curve( double *data_x, double *data, int n,
                 int x0, shock_tanh_param *param )
{
  int status;
  double *sigma;
  size_t i, iter = 0;
  fit_data d;
  const size_t p = 4;
  double x_init[4];
  double min,max;

  int win_elems;

  // if X0 estimate is > 0 then 
  if (x0 > 0)
  {
    win_elems = n * (WINDOW / 2.);
    data_x = &data_x[x0-win_elems];
    data   = &data  [x0-win_elems];
    n = win_elems * 2;
  }

  min = find_mean(data,n,0,n*0.1);
  max = find_mean(data,n,n*0.9,n);

  //A0
  x_init[0] = min;
  //CH
  x_init[1] = 1.0;
  //X0
  x_init[2] = ((data_x[n-1]-data_x[0])/2.0)+data_x[0];  //(n * g_dx)/2;
  //Y0
  x_init[3] = (max-min)/2.0+min;

  const gsl_multifit_fdfsolver_type *T;
  gsl_multifit_fdfsolver *s;

  const gsl_rng_type * type;
  gsl_rng * r;
  gsl_multifit_function_fdf f;

  gsl_vector_view x = gsl_vector_view_array (x_init, p);

  gsl_matrix *covar = gsl_matrix_alloc (p, p);

  sigma =  (double*)malloc( n * sizeof(double) );
  for (i = 0; i < n; i++)
    sigma[i] = 0.1;

  d.n = n;
  d.y = data;
  d.x = data_x;
  d.sigma = sigma;

  gsl_rng_env_setup();

  type = gsl_rng_default;
  r = gsl_rng_alloc (type);

  f.f = &expb_f;
  f.df = &expb_df;
  f.fdf = &expb_fdf;
  f.n = n;
  f.p = p;
  f.params = &d;


  T = gsl_multifit_fdfsolver_lmsder;
  s = gsl_multifit_fdfsolver_alloc (T, n, p);
  gsl_multifit_fdfsolver_set (s, &f, &x.vector);

  //  print_state (iter, s);

  iter = 0;
  do
    {
      iter++;
      status = gsl_multifit_fdfsolver_iterate (s);

      //      printf ("status = %s\n", gsl_strerror (status));
      //      print_state (iter, s);

      if (status)
        break;

      status = gsl_multifit_test_delta (s->dx, s->x,
                                        1e-4, 1e-4);
    }
  while (status == GSL_CONTINUE && iter < 500);

  gsl_multifit_covar (s->J, 0.0, covar);

  param->A0 = FIT(0);
  param->CH = FIT(1);
  param->X0 = FIT(2);
  param->Y0 = FIT(3);

  gsl_multifit_fdfsolver_free (s);

  free( sigma );

  return;

}

void
shock_cut_values( matrix *m )
{

  double max = -10000;

  int i,j,k,cnt;
  double med;
  int values,filter;
  int front_beg=0,front_end=0,front_tmp=0;

  values = m->x * SHOCK_FRONT_LENGTH;
  filter = m->x * SHOCK_FILTER_LENGTH;
  for ( i=0; i<m->y; i++ ) {

    for( j=0; j<m->x; j++ ) {
      med = 0.;
      for( k=j-filter; k<j; k++ ) {
	if( k<0 )
	  med += m->data[i][0];
	else
	  med += m->data[i][k];
      }
      med /= filter;

      if( m->data[i][j] > (2.0 * med) ) {
	//We probably found ramp
	front_tmp = j;
	break;
      }
    }

    if( front_tmp != j ) {
      //Pro pripady, ze by predchozi metoda selhala
      //Budu jednoduze hledat data > 2.0
      //Je to pouze nozove reseni.
      for( j=0; j<m->x; j++ ) {
	if( m->data[i][j] > 2.0 * m->data[i][0] ) {
	  front_tmp = j;
	  break;
	}
      }
    }

    //Find shock front peak in SHOCK_FRONT_LENGTH
    for( j=front_tmp; j<=front_tmp+values; j++ ) {
      if( m->data[i][j] > max ) {
	max = m->data[i][j];
	front_beg = j;
      }
    }
    front_end = m->x-1;
    for( j=front_beg+1; j<m->x; j++ ) {
      if( m->data[i][j] > max ) {
	front_end = j;
	break;
      }
    }
    med = 0.;
    cnt = 0;
    for( j=front_beg; j<= front_end; j++ ) {
      med += m->data[i][j];
      cnt++;
    }
    med /= cnt;
    for( j=0; j<m->x; j++ ) {
      if( m->data[i][j] > med )
	break;
    }
    for( ; j<m->x; j++ ) {
      m->data[i][j] = med;
    }
  }

}
