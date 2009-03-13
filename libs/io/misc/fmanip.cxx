/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   fmanip.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "fmanip.h"
#include "base/sys/assert.h"
#include "base/common/debug.h"
#include "pint/satmpi.h"

#define SATIO_PATH_SEPERATOR '/'

void IO::Mkdir (const String &path, mode_t mode)
{
  int length = path.Length();
  char *path_buf= new char[length+1];
  sprintf(path_buf,"%s",path.GetData ());
  struct stat status;
  int pos = length - 1;

  /* find part of path that has not yet been created */
  while ( (stat(path_buf,&status) != 0) && (pos >= 0) )
  {
    /* slide backwards in string until next slash found */
    bool slash_found = false;
    while ( (!slash_found) && (pos >= 0) )
    {
      if (path_buf[pos] == SATIO_PATH_SEPERATOR)
      {
	slash_found = true;
	if (pos >= 0) path_buf[pos] = '\0';
      }
      else
	pos--;
    }
  }

  /*
   * if there is a part of the path that already exists make sure it is really
   * a directory
   */
  if (pos >= 0)
  {
    if ( !S_ISDIR(status.st_mode) )
    {
      DBG_ERROR("IO::Mkdir(): cannot create directories in path: " << path);
      DBG_ERROR("  => an item in path already exists and is NOT a directory");
    }
  }
  /* make all directories that do not already exist */

  /*
   * if (pos < 0), then there is no part of the path that already exists.  Need
   * to make the first part of the path before sliding along path_buf.
   */
  if (pos < 0)
  {
    if(mkdir(path_buf,mode) != 0)
    {
      DBG_ERROR("IO::Mkdir(): Cannot create directory  = " << path_buf);
    }
    pos = 0;
  }

  /* make rest of directories */
  do
  {
    /* slide forward in string until next '\0' found */
    bool null_found = false;
    while ( (!null_found) && (pos < length) )
    {
      if (path_buf[pos] == '\0')
      {
	null_found = true;
	path_buf[pos] = SATIO_PATH_SEPERATOR;
      }
      pos++;
    }

    /* make directory if not at end of path */
    if (pos < length)
    {
      if(mkdir(path_buf,mode) != 0)
      {
	DBG_ERROR("IO::Mkdir(): Cannot create directory  = " << path_buf);
      }
    }
  }
  while (pos < length);

  delete [] path_buf;
}

void IO::Rename (const String &oldname, const String &newname)
{
  SAT_ASSERT (!oldname.IsEmpty ());
  SAT_ASSERT (!newname.IsEmpty ());
  rename (oldname.GetData (), newname.GetData ());
}

