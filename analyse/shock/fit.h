
#ifndef SHOCK_FIT_H
#define SHOCK_FIT_H

#include "common.h"
#include "util.h"

void
shock_cut_values( matrix *m );

void
shock_fit_curve( double *data_x, double *data, int x,
                 int x0, shock_tanh_param *param );

#endif //SHOCK_FIT_H
