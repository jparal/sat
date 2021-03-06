/*
  Copyright (C) 2005 by Jorrit Tyberghein
            (C) 2005 by Frank Richter

  This library is free software; you can redistribute it and/or
  modify it under the terms of the GNU Library General Public
  License as published by the Free Software Foundation; either
  version 2 of the License, or (at your option) any later version.

  This library is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  Library General Public License for more details.

  You should have received a copy of the GNU Library General Public
  License along with this library; if not, write to the Free
  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#ifndef __DEMANGLE_H__
#define __DEMANGLE_H__

#include "satconfig.h"
#include "base/common/string.h"
#include "base/sys/platform.h"

#ifdef HAVE_ABI_CXA_DEMANGLE_H
#include <cxxabi.h>
#endif

namespace SAT
{
  namespace Debug
  {

    static char* Demangle (const char* symbol)
    {
    #if defined(PLATFORM_COMPILER_GCC_CXX)
      /* Workaround: sometimes symbols are tried to be demangled which are
       * not method or function names; occasionally, libstdc++ chokes on
       * these. So don't try to demangle these */
      if ((symbol[0] != '_') || (symbol[1] != 'Z'))
        return strdup (symbol);
    #endif
#ifdef HAVE_ABI_CXA_DEMANGLE_H
      {
        int status;
        char* s = abi::__cxa_demangle (symbol, 0, 0, &status);
        if (status == 0) return s;
        if (s != 0) free (s);
      }
#endif
      return strdup (symbol);
    }

  } // namespace Debug
} // namespace SAT

#endif /* __DEMANGLE_H__ */
