/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   main.cxx
 * @brief  App for printing version of SAT.
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2007/07, @jparal}
 * @revmessg{Add -r parameter for revision (same like -p parameter)}
 */

#include <iostream>
#include "satconfig.h"

using namespace std;

#ifndef STRINGIFY
#  define _STRINGIFY_HELPER(x) #x
#  define STRINGIFY(x) _STRINGIFY_HELPER(x)
#endif

int main (int argc, char **argv)
{
  if (argc == 1)
  {
    cout << SAT_VERSION << "\n";
    return 0;
  }

  if (!strcmp(argv[1],"-f"))
    cout << SAT_VERSION << "\n";
  else if (!strcmp(argv[1],"-b"))
    cout << STRINGIFY(SAT_VERSION_BASE) << "\n";
  else if (!strcmp(argv[1],"-m"))
    cout << STRINGIFY(SAT_VERSION_MAJOR) << "\n";
  else if (!strcmp(argv[1],"-i"))
    cout << STRINGIFY(SAT_VERSION_MINOR) << "\n";
  else if (!strcmp(argv[1],"-u"))
    cout << STRINGIFY(SAT_VERSION_MICRO) << "\n";
  else if (!strcmp(argv[1],"-p") || !strcmp(argv[1],"-r"))
    cout << SAT_VERSION_PATCH << "\n";
  else if (!strcmp(argv[1],"-g"))
    cout << SAT_VERSION_GREEK << "\n";
  else if (!strcmp(argv[1],"-n"))
    cout << PACKAGE_NAME << "\n";
  else if (!strcmp(argv[1],"-s"))
    cout << PACKAGE_STRING << "\n";
  else if (!strcmp(argv[1],"-c"))
    cout << PACKAGE_COPYRIGHT << "\n";
  else
  {
    cout << "USAGE: sat-version [opt]\n\n";
    cout << "  -h     This help\n";
    cout << "  -f     Full version (default)\n";
    cout << "  -b     Base version\n";
    cout << "  -m     Major version\n";
    cout << "  -i     Minor version\n";
    cout << "  -u     Micro version\n";
    cout << "  -p|-r  Patch version\n";
    cout << "  -g     Greek version\n";
    cout << "\n";
    cout << "  -n     Package name\n";
    cout << "  -s     Package string\n";
    cout << "  -c     Package copyright\n";
    cout << "\n";
  }

  return 0;
}
