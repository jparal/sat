/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cfgfile.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

#include "base/sys/inline.h"
#include "base/common/debug.h"

template<class T, int D>
bool ConfigFile::GetValue(const char *path, Vector<T,D> &value,
			  const Vector<T,D> &def) const throw()
{
  try
  {
    ConfigEntry &entry = GetEntry(path);
    for (int i=0; i<D; ++i ) value[i] = (T)entry[i];
    return(true);
  }
  catch(ConfigFileException)
  {
    value = def;
    DBG_WARN ("configuration: '"<<path<<"' doesn't exist [default "<<def<<"]");
    return(false);
  }
}

template<class T, int D>
void ConfigFile::GetValue(const char *path, Vector<T,D> &value)
  const throw(ConfigFileException)
{
  ConfigEntry &entry = GetEntry(path);
  for (int i=0; i<D; ++i ) value[i] = (T)entry[i];
}

template<class T, int D>
bool ConfigEntry::GetValue(const char *path, Vector<T,D> &value, const Vector<T,D> &def)
  const throw()
{
  try
  {
    ConfigEntry &entry = operator[](path);
    for (int i=0; i<D; ++i) value[i] = (T)entry[i];
    return(true);
  }
  catch(ConfigFileException)
  {
    value = def;
    DBG_WARN ("configuration: '"<<path<<"' doesn't exist [default "<<def<<"]");
    return(false);
  }
}

template<class T, int D>
void ConfigEntry::GetValue(const char *path, Vector<T,D> &value)
  const throw(ConfigFileException)
{
  ConfigEntry &entry = operator[](path);
  for (int i=0; i<D; ++i ) value[i] = (T)entry[i];
}

template<class T, int D>
void ConfigEntry::GetValue(int pos, Vector<T,D> &value)
  const throw(ConfigFileException)
{
  SAT_ASSERT (pos < GetLength ());
  ConfigEntry &entry = operator[](pos);
  for (int i=0; i<D; ++i)
    value[i] = (T)entry[i];
}
