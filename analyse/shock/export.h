
#ifndef SHOCK_EXPORT_H
#define SHOCK_EXPORT_H

#include "util.h"
#include "common.h"

/**
 * Export routines:
 * (Each is placed in separated file)
 */

// @@@ CLEAN
void
shock_export_Lstat( shock_arg_param *p );

void
shock_export_info( shock_arg_param *p );

void
shock_export_foot( shock_arg_param *p );

void
shock_export_top( shock_arg_param *p );

void
shock_export_yft( shock_arg_param *p );

void
shock_export_Lfy( shock_arg_param *p );

void
shock_export_Npfx( shock_arg_param *p );

void
shock_export_tanh( shock_arg_param *p );

#endif //SHOCK_EXPORT_H
