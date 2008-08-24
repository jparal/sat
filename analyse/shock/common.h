
#ifndef SHOCK_COMMON_H
#define SHOCK_COMMON_H

#include "util.h"

typedef enum _exp_type {
  eEXP_NONE,
  eEXP_NPFX,
  eEXP_TANH,
  eEXP_LFY,
  eEXP_INFO,
  eEXP_FOOT,
  eEXP_TOP,
  eEXP_YFT
} exp_type;

typedef enum _layout_type {
  eLAYOUT_IDL,
  eLAYOUT_GNUPLOT
} layout_type;

// Global variables
typedef struct _shock_arg_param {
  int         secondFile;
  char       *fileName1;
  char       *fileName2;
  int         reflected;

  matrix     *Dn1,*Dn2;
  // consider only first 'cutoff' points fron x-axis
  int         cutoff;
  // estimation of x0 for Dn1 and Dn2 computed by 'shock_estimate_x0'
  int         x01, x02;


  exp_type    outType;
  layout_type layoutType;
  int         profile;

  double      dx;
  double      dy;
  double      vpx;
  double      dt;
  double      t1;
  double      t2;

} shock_arg_param;

// A0 * tanh( (x - X0)/CH ) + Y0
typedef struct _shock_tanh_param {
  double A0,CH,X0,Y0;
} shock_tanh_param;


void
shock_estimate_x0( shock_arg_param *p );

//Return -1 on parse error
double
shock_extract_time( char *name );

//Extract basename from src, add suffix and copy to dest (must be allocated)
void
shock_basename_addsuff_i( char *dest, char *src, int suff);

//Extract basename from src, add suffix and copy to dest (must be allocated)
void
shock_basename_addsuff_ch( char *dest, char *src, char *suff);

void
shock_error( char *msg );

double
shock_compute_L( shock_tanh_param *param );

void
shock_help();

#endif //SHOCK_COMMON_H
