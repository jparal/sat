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
  SAT_CALLGRIND_STOP_INSTRUMENTATION
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
      fld.Initialize (nx1+1, nx2+1, nx3+1);

  int i, j, k, cnt = 0;
  SAT_PRAGMA_OMP (private(i,j,k,cnt,buff,tmp,idx))
  for (k=1; k<=nx3; ++k)
    for (j=1; j<=nx2; ++j)
      for (i=1; i<=nx1; ++i)
      {
        if (cnt%5 == 0)
        {
          gzgets (file, buff, 256);
          sscanf (buff, "%lf %lf %lf %lf %lf",
                  &tmp[0], &tmp[1], &tmp[2], &tmp[3], &tmp[4]);
        }

	fld(i,j,k)[idx] = tmp[cnt%5];
        cnt++;
      }

  // set i=0 values
  for (k=0; k<=nx3; ++k)
    for (j=0; j<=nx2; ++j)
      fld(0,j,k)[idx] = fld(1,j,k)[idx];

  // set j=0 values
  for (k=0; k<=nx3; ++k)
    for (i=0; i<=nx1; ++i)
      fld(i,0,k)[idx] = fld(i,1,k)[idx];

  // set k=0 values
  for (j=0; j<=nx2; ++j)
    for (i=0; i<=nx1; ++i)
      fld(i,j,0)[idx] = fld(i,j,1)[idx];

  // average values to get cell => vertex conversion
  for (k=0; k<nx3; ++k)
    for (j=0; j<nx2; ++j)
      for (i=0; i<nx1; ++i)
	fld(i,j,k)[idx] = 0.125 *
	  (fld(i  ,j  ,k  )[idx] + fld(i  ,j  ,k+1)[idx] +
	   fld(i  ,j+1,k  )[idx] + fld(i  ,j+1,k+1)[idx] +
	   fld(i+1,j  ,k  )[idx] + fld(i+1,j  ,k+1)[idx] +
	   fld(i+1,j+1,k  )[idx] + fld(i+1,j+1,k+1)[idx]);

  gzclose (file);
  SAT_CALLGRIND_START_INSTRUMENTATION
}

template<class T> inline
void HIUtils::Load (Field<T,2> &fld, const char* path)
{
  //  SAT_CALLGRIND_STOP_INSTRUMENTATION
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
  //  SAT_CALLGRIND_START_INSTRUMENTATION
}
