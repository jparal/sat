
#include "util.h"
#include "parse.h"
#include "fit.h"
#include "common.h"
#include "export.h"

#include <stdio.h>

//Forward declarations
void shock_exit( int retCode );


int
main( int argc, char **argv )
{

  shock_arg_param *par;

  if ( argc < 2 ) {
    shock_help();
    exit( 1 );
  }

  par = (shock_arg_param*)malloc( sizeof( shock_arg_param ) );
  shock_parse_params( par, argc, argv );

  shock_parse_curves( par );

  shock_estimate_x0 (par);
/*   printf ("X0_1: %d\n", par->x01); */
/*   if ( par->secondFile ) */
/*     printf ("X0_2: %d\n", par->x02); */

  switch( par->outType ) {
  case eEXP_NPFX:
    shock_export_Npfx( par );
    break;
  case eEXP_TANH:
    shock_export_tanh( par );
    break;
  case eEXP_LFY:
    shock_export_Lfy( par );
    break;
  case eEXP_INFO:
    shock_export_info( par );
    break;
  case eEXP_FOOT:
    shock_export_foot( par );
    break;
  case eEXP_TOP:
    shock_export_top( par );
    break;
  case eEXP_YFT:
    shock_export_yft( par );
    break;
  default:
    shock_export_Lstat( par );
  };

  return 0;
}

void shock_exit( int retCode )
{
    //Free memory
  //@@@ make clean up
  //  matrix_del( datadn1 );
  //  matrix_del( datadn2 );

  exit( retCode );
}
