
#include "export.h"
#include "common.h"

#include <math.h>
#include <stdio.h>


void
shock_export_Npfx( shock_arg_param *p )
{
  int i;
  double xtmp;
  matrix *m = p->Dn1;
  int y = p->profile;

  printf( "%d\n", m->x );

  for ( i=0; i<m->x; i++ ) {
    xtmp = m->data_x[i]; //(double)(i) * g_dx;
    printf( "%lf %lf\n", xtmp, m->data[y][i] );
  }
}

