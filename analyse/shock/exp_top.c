
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>


void
shock_export_top( shock_arg_param *p )
{
  int i;
  double Ltmp;
  shock_tanh_param param;
  int top = p->profile;
  matrix *m = p->Dn1;

  if ( top <= 0 ) {
    for ( i=0; i<m->y; i++ ) {
      shock_fit_curve( m->data_x, m->data[i], m->x, p->x01, &param );
      Ltmp = shock_compute_L( &param );
      printf("%lf ",  param.X0 + Ltmp/2.0 );
    }
  } else {

    if ( top > m->y )
      shock_error("Error: Bad -top parametr\n");

    shock_fit_curve( m->data_x, m->data[top-1], m->x, p->x01, &param );
    Ltmp = shock_compute_L( &param );

    printf("%lf", param.X0 + Ltmp/2.0 );
  }
  printf("\n");
}
