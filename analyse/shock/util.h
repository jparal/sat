
#ifndef SHOCK_UTIL_H
#define SHOCK_UTIL_H

#include <stdlib.h>

typedef struct matrix_
{
  double **data;
  //Data on x-axis (from file or generated from -dx param )
  double *data_x;
  size_t x;
  size_t y;

} matrix;

// Matrix alocation

matrix*
matrix_new(long x, size_t y);

void
matrix_del( matrix *m );

matrix*
matrix_cpy( matrix *m );

double
find_min( double *d, int n );

double
find_max( double *d, int n );

double
find_mean( double *d, int n, int from, int to );

#endif //SHOCK_UTIL_H
