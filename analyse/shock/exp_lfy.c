
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>


void
shock_export_Lfy( shock_arg_param *p )
{
  int i;
  double Ltmp;
  shock_tanh_param param;
  matrix *m = p->Dn1;

  for ( i=0; i<m->y; i++ ) {
    shock_fit_curve( m->data_x, m->data[i], m->x, p->x01, &param );
    Ltmp = shock_compute_L( &param );

    printf( "%lf %lf\n",p->dy*i,Ltmp );
  }
}
