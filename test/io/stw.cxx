/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   stw.cxx
 * @brief  STW I/O tests
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-09, @jparal}
 * @revmessg{Initial version}
 */

#include "sattest.h"
#include "satio.h"

#define D1 20
#define D2 20
#define EPS 0.001

SUITE (StwSuite)
{
  TEST (FileTest)
  {
    Vector<int,2> so (D1, D2);

    StwFile<3> file;
    file.Open ("B", "bla", File::Out | File::Gz);
    file.WriteHeader (so);

    float cnt = 0.1;
    for (int j=0; j<so[1]; ++j)
      for (int i=0; i<so[0]; ++i)
      {
	Vector<float, 3> val(cnt++);
	file.Write (val);
      }

    file.Close ();

    cnt = 0.1;
    file.Open ("B", "bla", File::In | File::Gz);
    Vector<int,2> si;
    file.ReadHeader (si);
    CHECK (so == si);
    for (int j=0; j<si[1]; ++j)
      for (int i=0; i<si[0]; ++i)
      {
	Vector<float, 3> val;
	file.Read (val);
	Vector<float, 3> expect(cnt++);
	for (int i=0; i<3; ++i)
	  CHECK_CLOSE(expect[i], val[i], EPS);
      }

  }
}
