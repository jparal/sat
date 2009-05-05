/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   utils.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2009/04, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "pint/satomp.h"

template<class T> inline
void HIUtils::Load (Field<T,3> &fld, int idx, const char* path)
{
  int dims;
  double tmp[5];
  char buff[256];

  gzFile file = gzopen (path,"r");

  DBG_INFO ("Loading file: " <<path);

  if (file == NULL)
  {
    DBG_ERROR ("Loading file failed: "<<path);
    return;
  }

  int nx1, nx2, nx3;
  gzgets (file, buff, 256);
  dims = sscanf (buff, "%d %d %d", &nx1, &nx2, &nx3);

  SAT_PRAGMA_OMP (critical)
    if (!fld.Initialized ())
      fld.Initialize (nx1, nx2, nx3);

  int i, j, k, cnt = 0;
  SAT_PRAGMA_OMP (private(i,j,k,cnt,buff,tmp,idx))
  for (k=0; k<nx3; k++) {
    for (j=0; j<nx2; j++) {
      for (i=0; i<nx1; i++)
      {
        if (cnt%5 == 0)
        {
          gzgets (file, buff, 256);
          sscanf (buff, "%lf %lf %lf %lf %lf",
                  &tmp[0], &tmp[1], &tmp[2], &tmp[3], &tmp[4]);
        }

	fld (i, j, k)[idx] = tmp[cnt%5];
        cnt++;
      }
    }
  }

  gzclose (file);
}

template<class T> inline
void HIUtils::Load (Field<T,2> &fld, const char* path)
{
  int dims;
  double tmp[5];
  char buff[256];

  gzFile file = gzopen (path,"r");

  DBG_INFO ("Loading file: " <<path);

  if (file == NULL)
  {
    DBG_ERROR ("Loading file failed: "<<path);
    return;
  }

  int nx1, nx2;
  gzgets (file, buff, 256);
  dims = sscanf (buff, "%d %d", &nx1, &nx2);

  SAT_PRAGMA_OMP (critical)
    if (!fld.Initialized ())
      fld.Initialize (nx1, nx2);

  int i, j, cnt = 0;
  SAT_PRAGMA_OMP (private(i,j,cnt,buff,tmp,idx))
    for (j=0; j<nx2; j++) {
      for (i=0; i<nx1; i++)
      {
        if (cnt%5 == 0)
        {
          gzgets (file, buff, 256);
          sscanf (buff, "%lf %lf %lf %lf %lf",
                  &tmp[0], &tmp[1], &tmp[2], &tmp[3], &tmp[4]);
        }

	fld (i, j) = tmp[cnt%5];
        cnt++;
      }
    }

  gzclose (file);
}
