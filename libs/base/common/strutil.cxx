/*
    Copyright (C) 1998 by Jorrit Tyberghein

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

// #include "satsysdef.h"
// #include "sattypes.h"

#include "strutil.h"
#include "base/sys/stdhdrs.h"

// static const size_t shortStringChars = 64;

char *StrNew (const char *s)
{
  if (s)
  {
    size_t sl = strlen (s) + 1;
    char *r = new char [sl];
    memcpy (r, s, sl);
    return r;
  }
  else
    return 0;
}

// These functions are not inline in <util/util.h> because the underlying
// str{n}casecmp() is not compatible with gcc's "-ansi -pedantic".
int StrCaseCmp(char const* s1, char const* s2)
{
  return strcasecmp(s1, s2);
}
int StrNCaseCmp(char const* s1, char const* s2, size_t n)
{
  return strncasecmp(s1, s2, n);
}

#define IS_PATH_SEPARATOR(c)				\
  ((c) == '/')

void SplitPath (const char *iPathName, char *oPath, size_t iPathSize,
  char *oName, size_t iNameSize)
{
  size_t sl = strlen (iPathName);
  size_t maxl = sl;
  while (sl && (!IS_PATH_SEPARATOR (iPathName [sl - 1])))
    sl--;

  if (iPathSize)
    if (sl >= iPathSize)
    {
      memcpy (oPath, iPathName, iPathSize - 1);
      oPath [iPathSize - 1] = 0;
    }
    else
    {
      memcpy (oPath, iPathName, sl);
      oPath [sl] = 0;
    }

  if (iNameSize)
    if (maxl - sl >= iNameSize)
    {
      memcpy (oName, &iPathName [sl], iNameSize - 1);
      oName [iNameSize - 1] = 0;
    }
    else
      memcpy (oName, &iPathName [sl], maxl - sl + 1);
}

bool GlobMatches (const char *fName, const char *fMask)
{
  while (*fName || *fMask)
  {
    if (*fMask == '*')
    {
      while (*fMask == '*')
        fMask++;
      if (!*fMask)
        return true;		// mask = "something*"
      while (*fName && *fName != *fMask)
        fName++;
      if (!*fName)
        return false;		// "*C" - fName does not contain C
    }
    else
    {
      if ((*fMask != '?')
       && (*fName != *fMask))
        return false;
      if (*fMask)
        fMask++;
      if (*fName)
        fName++;
    }
  }
  return (!*fName) && (!*fMask);
}

/**
 * given src and dest, which are already allocated, copy source to dest.
 * But, do not copy 'search', instead replace that with 'replace' string.
 * max is size of dest
*/
void ReplaceAll(char *dest, const char *src, const char *search,
  const char *replace, int max)
{
  const char *found;
  const char *srcpos = src;
  char *destpos = dest;
  size_t searchlen = strlen (search);
  size_t replacelen = strlen (replace);
  destpos[0] = 0;
  size_t sizeleft = max;
  /// find and replace occurrences
  while( (found=strstr(srcpos, search)) != 0 )
  {
    // copy string before it
    int beforelen = found - srcpos;
    sizeleft -= beforelen;
    if(sizeleft <= 0) { destpos[0]=0; return; }
    memcpy (destpos, srcpos, beforelen);
    destpos += beforelen;
    srcpos += beforelen;
    destpos[0]=0;
    // add replacement
    sizeleft -= replacelen;
    if(sizeleft <= 0) { destpos[0]=0; return; }
    strcpy(destpos, replace);
    destpos += replacelen;
    // skip replaced string
    srcpos += searchlen;
  }
  // add remainder of string
  size_t todo = strlen (srcpos);
  sizeleft -= todo;
  if(sizeleft <= 0) { destpos[0]=0; return; }
  strcpy (destpos, srcpos);
  destpos += todo;
  destpos[0]=0;
}
