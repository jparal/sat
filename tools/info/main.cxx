/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   main.cxx
 * @brief  App for printing various info from configure and header files
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/07, @jparal}
 * @revmessg{Make the output more readable and get rid of some testing I was
 *          playing with before.}
 */

#include <iostream>
#include <sys/time.h>
#include <sys/times.h>

#include "satbase.h"
#include "satpint.h"

using namespace std;

#define DISP(x)						\
  if (strcmp (""#x"", _STRINGIFY(x))) {			\
    std::cout << ""#x":\t " << _STRINGIFY(x) << "\n";	\
  } else {						\
    std::cout << ""#x":\t " << "Not defined\n";		\
  }

#define PRNT(x) std::cout << ""#x":\t " << x << "\n";

int main (int argc, char **argv)
{
  cout << "\nPackage:\n\n";
  PRNT(PACKAGE_NAME);
  PRNT(CONFIGURE_DATE);
  DISP(SAT_VERSION_BASE);
  PRNT(CONFIGURE_UNAME);

  cout << "\nAttributes:\n\n";
  DISP(SAT_INLINE);
  DISP(SAT_INLINE_ALWAYS);
  DISP(SAT_INLINE_FLATTEN);
  DISP(SAT_ATTR_DEPRECATED);
  DISP(SAT_ATTR_NORETURN);

  cout << "\nPlatform:\n\n";
  DISP(PLATFORM_OS_FAMILYNAME);
  DISP(PLATFORM_ARCH_FAMILYNAME);
  DISP(PLATFORM_COMPILER_FAMILYNAME);
  DISP(PLATFORM_COMPILER_FAMILYID);
  DISP(PLATFORM_COMPILER_ID);
  PRNT(PLATFORM_COMPILER_VERSION_STR);
  PRNT(PLATFORM_COMPILER_VERSION);

  DISP(PLATFORM_ARCH_32);
  DISP(PLATFORM_ARCH_64);
  DISP(PLATFORM_ARCH_LITTLE_ENDIAN);
  DISP(PLATFORM_ARCH_BIG_ENDIAN);

  cout << "\nOptimization:\n\n";
  DISP(if_pf(exp));
  DISP(if_pt(exp));
  DISP(PREDICT_TRUE(exp));
  DISP(PREDICT_FALSE(exp));
  DISP(SAT_PREFETCH_RO(mem));
  DISP(SAT_PREFETCH_RW(mem));
}
