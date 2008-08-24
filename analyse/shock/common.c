
//#include "sat/base.h"
#include "common.h"
#include "fit.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

// Global variables
int     g_reflected  = 0;    //Count with reflected particles before ramp.
int     g_secondfile = 0;    //Do we have two files in input args?
int     g_Npfx       = 0;    //Export one profile from input files
int     g_tanh       = 0;    //Export tanh for given profile (y)
int     g_Lfy        = 0;    //Export L = f(y)
int     g_info       = -1;   //Info for profile g_info
int     g_foot       = -1;   //Export value where ramp begins
int     g_top        = -1;   //Export value where ramp ends
double  g_dx         = 0.1;  //scale on x axis
double  g_dy         = 0.3;  //scale on x axis
double  g_vpx        = 4.5;  //Velocity of sun wind (particles)
double  g_dt         = 1;    //scale of time
double  g_t1         = -1;   //time of file 1
double  g_t2         = -1;   //time of file 1
char   *g_file1name  = NULL;
char   *g_file2name  = NULL;

void
shock_estimate_x0( shock_arg_param *p )
{
  int i, cnt;
  shock_tanh_param param;
  double C1;

  matrix *dn1 = p->Dn1;
  matrix *dn2 = p->Dn2;

  ////FILE 1
  C1 = 0; cnt = 0;
  for ( i=0; i<dn1->y; i++ ) {
    shock_fit_curve( dn1->data_x, dn1->data[i], dn1->x, -1., &param );
    if (param.X0 < (p->dx * dn1->x) && param.X0 > 0.)
    {
      ++cnt;
      C1 += param.X0;
    }
  }
  // Compute <L>
  C1 /= (double)cnt;
  p->x01 = (int)(C1/p->dx);

  //FILE 2
  if ( !p->secondFile )
    return;

  C1 = 0;
  for ( i=0; i<dn2->y; i++ ) {
    shock_fit_curve( dn2->data_x, dn2->data[i], dn2->x, -1., &param );
    C1 += param.X0;
  }
  // Compute <L>
  C1 /= dn2->y;
  p->x02 = (int)(C1/p->dx);
}

void
shock_error( char *msg )
{
  printf( "%s\n",msg );
  exit( 1 );
}

double
shock_extract_time( char *name )
{
  char *chtime;
  int time;

  chtime = (char*)strrchr( name, 't' );
  if ( chtime == NULL )
    return -1;
 
  time = atoi( chtime+1 );
  if ( time == 0 )
    return -1;
  else
    return time;
}

//Extract basename from src, add suffix and copy to dest (must be allocated)
void
shock_basename_addsuff_i( char *dest, char *src, int suff)
{
  char *name;

  name = (char*)strrchr( src, '/' );
  if ( name == NULL ) {
    //File name is short
    name = src;
  } else {
    //File is with slash, so add one
    name++;
  }

  strcpy(dest,name);
  sprintf(dest + strlen(name), ".%d",suff);

}

//Extract basename from src, add suffix and copy to dest (must be allocated)
void
shock_basename_addsuff_ch( char *dest, char *src, char *suff)
{
  char *name;

  name = (char*)strrchr( src, '/' );
  if ( name == NULL ) {
    //File name is short
    name = src;
  } else {
    //File is with slash, so add one
    name++;
  }

  strcpy(dest,name);
  sprintf(dest + strlen(name), ".%s",suff);

}

double
shock_compute_L( shock_tanh_param *param )
{
  double CH;

  CH = param->CH;

  // L = 2 * CH * arctanh( .95 )
  return fabs( 2.0 * CH * 1.831780823 );

  // or: L = CH * arctanh( .95 ) as Stuart
  //  return CH * 1.831780823;
}


void shock_help()
{
#ifdef _SAT_INFO_H_
  sat_info_banner_print( "Shock Wave Analyser" );
  printf( "\n" );
#else
  printf("Shock analyser "); 
  printf(" , Jan Paral (paral@alenka.ufa.cas.cz)\n\n");
#endif
  printf("USAGE : shock [options] file1 [ file2 ]\n\n");

  printf("-h | --help        this help\n\n");

  printf("  input options:\n");
  printf("-dx <num>     scale of x axis ( default 0.1 )\n");
  printf("-dy <num>     scale of y axis ( default 0.3 )\n");
  printf("-dt <num>     scale of time ( default 1 )\n");
  printf("-t1 <num>     time of shock in file1 (default from file name)\n");
  printf("-t2 <num>     time of shock in file2 (default from file name)\n");
  printf("-vpx <num>    velocity of plasma( default 4.5 )\n");
  printf("-coff <num>   consider only first 'cutoff' cells fron x-axis\n");
  printf("file          name of file where t1 < t2\n\n");

  printf("  output options:\n");
  printf("-gradb        exprot grad B.\n");
  printf("-Npfx <num>   export Np = f(x) (specified profile from shock).\n");
  printf("-Lfy          export L  = f(y) to file \"input_file.Lfy\" \n");
  printf("-tanh         export fitted tanh for gives profiles\n");
  printf("-i  [num]     info of profile <num>. Or params for all profiles.\n");
}
