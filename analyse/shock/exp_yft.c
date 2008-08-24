
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>


void
shock_export_yft( shock_arg_param *p )
{
  int i;
  double Ltmp;
  shock_tanh_param param;
  int yft = p->profile;
  matrix *m = p->Dn1;

  if ( yft <= 0 ) {
    for ( i=0; i<m->y; i++ ) {
      shock_fit_curve( m->data_x, m->data[i], m->x, p->x01, &param );
      Ltmp = shock_compute_L( &param );
      printf("%lf %lf %lf\n", (double)i * p->dy,
             param.X0 - Ltmp/2.0, param.X0 + Ltmp/2.0 );

    }
  } else {

    if ( yft > m->y )
      shock_error("Error: Bad -yft parametr\n");

    shock_fit_curve( m->data_x, m->data[yft-1], m->x, p->x01, &param );
    Ltmp = shock_compute_L( &param );

    printf("%lf %lf %lf\n", (double)yft * p->dy,
           param.X0 - Ltmp/2.0, param.X0 + Ltmp/2.0 );
  }
}
