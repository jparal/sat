
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>


void
shock_export_tanh( shock_arg_param *p )
{
  int i;
  double xtmp;
  double tanhtmp;
  shock_tanh_param param;
  matrix *m = p->Dn1;
  int y = p->profile;

  if( p->layoutType == eLAYOUT_IDL )
    printf( "%u\n", (unsigned int)m->x );

  shock_fit_curve( m->data_x, m->data[y-1], m->x, p->x01, &param );

  for ( i=0; i<m->x; i++ ) {
    xtmp = m->data_x[i]; //(double)(i)*g_dx;
    tanhtmp = param.A0 * tanh( ( xtmp - param.X0 ) / param.CH ) + param.Y0;
    printf( "%lf %lf\n", xtmp, tanhtmp );
  }
}
