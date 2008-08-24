
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>

void
shock_export_info(  shock_arg_param *p )
{
  int i;
  double Ltmp;
  shock_tanh_param param;
  int info = p->profile;
  matrix *m = p->Dn1;
  
  if ( info < 0 ) {
    for ( i=0; i<m->y; i++ ) {
      shock_fit_curve( m->data_x, m->data[i], m->x, p->x01, &param );
      Ltmp = shock_compute_L( &param );
      printf("(A0,CH,X0,Y0,L,y,t)= %lf %lf %lf %lf %lf %lf %lf\n", param.A0,
	     param.CH,param.X0,param.Y0,Ltmp,i*p->dy,p->t1*p->dt);
    }
  } else {

    if ( p->profile > m->y )
      shock_error("Error: Bad -i parametr\n");

    shock_fit_curve( m->data_x, m->data[info-1], m->x, p->x01, &param );
    Ltmp = shock_compute_L( &param );
    
    printf("(A0,CH,X0,Y0,L,y,t)= %lf %lf %lf %lf %lf %lf %lf\n", param.A0,
	   param.CH,param.X0,param.Y0,Ltmp,(info-1)*p->dy,p->t1*p->dt);
  }
}
