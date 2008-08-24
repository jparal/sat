
#include "export.h"
#include "common.h"
#include "fit.h"

#include <math.h>
#include <stdio.h>


void
shock_export_Lstat( shock_arg_param *p )
{
  int i;
  double L1, L2, *L, Ldelta, Ltmp;
  double dL1=0.,dL2=0.;
  double vsh,dt;
  double vxdelta,vxtmp,vxm,C1m,C2m;  
  shock_tanh_param param;
  double *C1,*C2;

  matrix *dn1 = p->Dn1;
  matrix *dn2 = p->Dn2;

  L  = (double*)malloc( dn1->y * sizeof(double) );
  C1 = (double*)malloc( dn1->y * sizeof(double) );

  ////FILE 1
  L1 = 0;
  for ( i=0; i<dn1->y; i++ ) {
    shock_fit_curve( dn1->data_x, dn1->data[i], dn1->x, p->x01, &param );
    Ltmp = shock_compute_L( &param );

    L[i] = Ltmp;
    C1[i] = param.X0;
    L1 += Ltmp;

  }
  // Compute <L>
  L1 /= dn1->y;

  Ldelta = 0;
  dL1 = 0;
  for ( i=0; i<dn1->y; i++ ) {
    Ldelta += ( L1 - L[i] ) * ( L1 - L[i] );
    if ( fabs(L1-L[i]) > dL1 )
      dL1 = fabs(L1-L[i]);
  }
  Ldelta /= dn1->y - 1;
  Ldelta = sqrt( Ldelta );
    
  if( dn1->y > 1 )
    printf( "L1(dL)= %lf +/- %lf %lf\n", L1, Ldelta, dL1 );
  else
    printf( "L1= %lf\n", L1 );
  
  free( L );

  //FILE 2
  if ( p->secondFile ) {

    L  = (double*)malloc( dn2->y * sizeof(double) );
    C2 = (double*)malloc( dn2->y * sizeof(double) );

    L2 = 0;
    for ( i=0; i<dn2->y; i++ ) {
      shock_fit_curve( dn2->data_x, dn2->data[i], dn2->x, p->x02, &param );
      Ltmp = shock_compute_L( &param );

      L[i] = Ltmp;
      C2[i] = param.X0;
      L2 += Ltmp;
    }
    // Compute <L>
    L2 /= dn2->y;

    Ldelta = 0;
    for ( i=0; i<dn2->y; i++ ) {
      Ldelta += ( L2 - L[i] ) * ( L2 - L[i] );
      if ( fabs(L2-L[i]) > dL2 )
	dL2 = fabs(L2-L[i]);
    }
    Ldelta /= dn2->y - 1;
    Ldelta = sqrt( Ldelta );

    printf( "L2= %lf +/- %lf\n", L2, Ldelta );
    free( L );

    if( p->t1 == -1 || p->t2 == -1 )
      shock_error( "Error: Specify times of files ( -t1, -t2 )." );

    //Compute velocity
    dt = (p->t2 - p->t1) * p->dt;
    vxdelta = 0; C1m = 0; C2m = 0; vxm = 0;
    for ( i=0; i<dn2->y ; i++ ) {
      vxm += ( C1[i] - C2[i] ) / dt;
    }
    vxm /= dn2->y;
    for ( i=0; i<dn2->y; i++ ) {
      vxtmp = ( C1[i] - C2[i] ) / dt;
      vxdelta += fabs( vxtmp - vxm );
    }
    vxdelta /= dn2->y - 1;
    vxdelta = sqrt( vxdelta );

    vsh = vxm + p->vpx;

    //    printf ("vpx: %lf, vxm: %lf\n", p->vpx, vxm);
    printf( "v_sh= %lf +/- %lf\n",vsh,vxdelta );
  }
}

