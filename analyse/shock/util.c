
#include "util.h"

#include <stddef.h>


matrix*
matrix_new(long x, size_t y)
{
  matrix *m;
  int i;

  m = (matrix*)malloc( sizeof( matrix ) );

  m->x = x;
  m->y = y;

  m->data_x = (double*)malloc( x * sizeof( double ) );
  m->data = (double**)malloc( y * sizeof( double* ) );
  for( i=0; i<y; i++ )
    {
      m->data[i] = (double*)malloc( x * sizeof( double ) );
    }

  return m;
}

void
matrix_del( matrix *m )
{
  /*
  size_t y;
  int i;

  y = m->y;
  for( i=0; i<y; i++ )
    {
      free( m->data[i] );
    }

  free( m->data );
  free( m );
  */
}


matrix*
matrix_cpy( matrix *m )
{
  matrix *r;
  int i;

  r = (matrix*)malloc( sizeof( matrix ) );

  r->x = m->x;
  r->y = m->y;

  r->data_x = (double*) malloc( r->x * sizeof( double  ) );
  r->data   = (double**)malloc( r->y * sizeof( double* ) );
  for( i=0; i<r->y; i++ )
    {
      r->data[i] = (double*)malloc( r->x * sizeof( double ) );
    }

  return m;
}

double
find_min( double *d, int n )
{
  int i;
  double min;

  if( n > 0 )
    min = d[0];
  else
    return 0.;

  for( i=0; i<n; i++ )
    {
      if( min > d[i] )
	min = d[i];
    }
  return min;
}

double
find_max( double *d, int n )
{
  int i;
  double max;

  if( n > 0 )
    max = d[0];
  else
    return 0.;

  for( i=0; i<n; i++ )
    {
      if( max < d[i] )
	max = d[i];
    }
  return max;
}


double
find_mean( double *d, int n, int from, int to )
{
  int i,cnt = 1;
  double mean = 0.0;

      if( from < 0 )
	return 0.;
      if( from > to )
	return 0;

  for( i=from; i<to; i++ )
    {
      if( i==n )
	break;
      mean += d[i];
      cnt++;
    }

  mean /= cnt;
  return mean;
}
