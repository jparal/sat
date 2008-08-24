/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filexdmf.cxx
 * @brief  XDMF file I/O
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "sat.h"

SUITE (XdmfSuite)
{
  TEST (WriteTest)
  {
    typedef Field<float,3> ScaField;
    typedef Field<Vector<float,3>,3> VecField;

    ScaField sfld (10, 10, 10);
    //    VecField vfld (10, 10, 10);

    // XdmfFile file;
    // file.Write (sfld);
    //    file.Write (vfld);
  }
}
