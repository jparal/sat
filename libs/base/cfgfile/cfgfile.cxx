/* ----------------------------------------------------------------------------
   libconfig - A structured configuration file parsing library
   Copyright (C) 2005-2007  Mark A Lindner

   This file is part of libconfig.

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public License
   as published by the Free Software Foundation; either version 2.1 of
   the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
   ----------------------------------------------------------------------------
*/

#include "satsysdef.h"
#include "cfgfile.h"
#include "base/common/debug.h"
#include <sstream>

#ifdef _MSC_VER
#pragma warning (disable: 4996)
#endif

// ---------------------------------------------------------------------------

static int __toTypeCode(ConfigEntry::Type type)
{
  int typecode;

  switch(type)
  {
    case ConfigEntry::TypeGroup:
      typecode = CONFIG_TYPE_GROUP;
      break;

    case ConfigEntry::TypeInt:
      typecode = CONFIG_TYPE_INT;
      break;

    case ConfigEntry::TypeFloat:
      typecode = CONFIG_TYPE_FLOAT;
      break;

    case ConfigEntry::TypeString:
      typecode = CONFIG_TYPE_STRING;
      break;

    case ConfigEntry::TypeBoolean:
      typecode = CONFIG_TYPE_BOOL;
      break;

    case ConfigEntry::TypeArray:
      typecode = CONFIG_TYPE_ARRAY;
      break;

    case ConfigEntry::TypeList:
      typecode = CONFIG_TYPE_LIST;
      break;

    default:
      typecode = CONFIG_TYPE_NONE;
  }

  return(typecode);
}

// ---------------------------------------------------------------------------

static void __constructPath(const ConfigEntry &setting,
                            String &path)
{
  // head recursion to print path from root to target

  if(! setting.IsRoot())
  {
    __constructPath(setting.GetParent(), path);
    //    if(path.tellp())
    if(path.Length ())
      path << '.';

    const char *name = setting.GetName();
    if(name)
      path << name;
    else
      path << '[' << setting.GetIndex() << ']';
  }
}

// ---------------------------------------------------------------------------

void ConfigFile::ConfigFileDestructor(void *arg)
{
  delete reinterpret_cast<ConfigEntry *>(arg);
}

// ---------------------------------------------------------------------------

ConfigFile::ConfigFile()
{
  config_init(& _config);
  config_set_destructor(& _config, ConfigFileDestructor);
}

// ---------------------------------------------------------------------------

ConfigFile::~ConfigFile()
{
  config_destroy(& _config);
}

// ---------------------------------------------------------------------------

void ConfigFile::SetAutoConvert(bool flag)
{
  config_set_auto_convert(& _config, (flag ? CONFIG_TRUE : CONFIG_FALSE));
}

// ---------------------------------------------------------------------------

bool ConfigFile::GetAutoConvert() const
{
  return(config_get_auto_convert(& _config) != CONFIG_FALSE);
}

// ---------------------------------------------------------------------------

void ConfigFile::Read(FILE *stream)
  throw(ParseException)
{
  if(! config_read(& _config, stream))
    throw ParseException(config_error_line(& _config),
                         config_error_text(& _config));
}

// ---------------------------------------------------------------------------

void ConfigFile::Write(FILE *stream) const
{
  config_write(& _config, stream);
}

// ---------------------------------------------------------------------------

void ConfigFile::ReadFile(const char *filename)
  throw(FileIOException, ParseException)
{
  FILE *f = fopen(filename, "rt");
  if(f == NULL)
    throw FileIOException();
  try
  {
    Read(f);
    fclose(f);
  }
  catch(ParseException& p)
  {
    fclose(f);
    throw p;
  }
}

// ---------------------------------------------------------------------------

void ConfigFile::WriteFile(const char *filename)
  throw(FileIOException)
{
  if(! config_write_file(& _config, filename))
    throw FileIOException();
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigFile::GetEntry(const char *path) const
  throw(ConfigEntryNotFoundException)
{
  config_setting_t *s = config_lookup(& _config, path);
  if(! s)
    throw ConfigEntryNotFoundException();

  return(ConfigEntry::WrapConfigEntry(s));
}

// ---------------------------------------------------------------------------

bool ConfigFile::Exists(const char *path) const throw()
{
  config_setting_t *s = config_lookup(& _config, path);

  return(s != NULL);
}

// ---------------------------------------------------------------------------

#define CONFIG_LOOKUP_NO_EXCEPTIONS(P, T, V, D)				\
  try									\
  {									\
    ConfigEntry &s = GetEntry(P);					\
    V = (T)s;								\
    return(true);							\
  }									\
  catch(ConfigEntryNotFoundException)					\
  {									\
    V = D;								\
    DBG_WARN ("configuration: '"<<P<<"' doesn't exist [default "<<D<<"]"); \
    return(false);							\
  }

#define CONFIG_LOOKUP_EXCEPTIONS(P, T, V)		\
    ConfigEntry &s = GetEntry(P);			\
    V = (T)s;

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, bool &value, bool def) const
  throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, bool, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, long &value, long def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, long, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, unsigned long &value, unsigned long def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, unsigned long, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, int &value, int def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, int, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, unsigned int &value, unsigned int def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, unsigned int, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, double &value, double def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, double, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, float &value, float def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, float, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, const char *&value, const char *def) const throw()
{ CONFIG_LOOKUP_NO_EXCEPTIONS(path, const char *, value, def); }

// ---------------------------------------------------------------------------

bool ConfigFile::GetValue(const char *path, String &value, String def) const throw()
{
  // try
  // {
  //   ConfigEntry &s = GetEntry(path);
  //   value = (const char*)s;
  //   return(true);
  // }
  // catch(ConfigEntryNotFoundException)
  // {
  //   value = def;
  //   DBG_WARN ("configuration: '"<<path<<"' doesn't exist [default "<<def<<"]");
  //   return(false);
  // }

  CONFIG_LOOKUP_NO_EXCEPTIONS(path, const char*, value, def);
}

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, bool &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, bool, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, long &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, long, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, unsigned long &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, unsigned long, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, int &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, int, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, unsigned int &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, unsigned int, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, double &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, double, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, float &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, float, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, const char *&value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, const char *, value); }

// ---------------------------------------------------------------------------

void ConfigFile::GetValue(const char *path, String &value) const
  throw(ConfigFileException)
{ CONFIG_LOOKUP_EXCEPTIONS(path, const char *, value); }

// ---------------------------------------------------------------------------

ConfigEntry & ConfigFile::GetRoot() const
{
  return(ConfigEntry::WrapConfigEntry(config_root_setting(& _config)));
}

// ---------------------------------------------------------------------------

ConfigEntry::ConfigEntry(config_setting_t *setting)
  : _setting(setting)
{
  switch(config_setting_type(setting))
  {
    case CONFIG_TYPE_GROUP:
      _type = TypeGroup;
      break;

    case CONFIG_TYPE_INT:
      _type = TypeInt;
      break;

    case CONFIG_TYPE_FLOAT:
      _type = TypeFloat;
      break;

    case CONFIG_TYPE_STRING:
      _type = TypeString;
      break;

    case CONFIG_TYPE_BOOL:
      _type = TypeBoolean;
      break;

    case CONFIG_TYPE_ARRAY:
      _type = TypeArray;
      break;

    case CONFIG_TYPE_LIST:
      _type = TypeList;
      break;

    case CONFIG_TYPE_NONE:
    default:
      _type = TypeNone;
      break;
  }

  switch(config_setting_get_format(setting))
  {
    case CONFIG_FORMAT_HEX:
      _format = FormatHex;
      break;

    case CONFIG_FORMAT_DEFAULT:
    default:
      _format = FormatDefault;
      break;
  }
}

// ---------------------------------------------------------------------------

ConfigEntry::~ConfigEntry() throw()
{
  _setting = NULL;
}

// ---------------------------------------------------------------------------

void ConfigEntry::SetFormat(Format format) throw()
{
  if(_type == TypeInt)
  {
    if(format ==FormatHex)
      _format = FormatHex;
    else
      _format = FormatDefault;
  }
  else
    _format = FormatDefault;
}

// ---------------------------------------------------------------------------

ConfigEntry::operator bool() const throw(ConfigEntryTypeException)
{
  assertType(TypeBoolean);

  return(config_setting_get_bool(_setting) ? true : false);
}

// ---------------------------------------------------------------------------

ConfigEntry::operator long() const throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  return(config_setting_get_int(_setting));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator unsigned long() const throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  long v = config_setting_get_int(_setting);

  if(v < 0)
    v = 0;

  return(static_cast<unsigned long>(v));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator int() const throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  // may cause loss of precision:
  return(static_cast<int>(config_setting_get_int(_setting)));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator unsigned int() const throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  long v = config_setting_get_int(_setting);

  if(v < 0)
    v = 0;

  return(static_cast<unsigned int>(v));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator double() const throw(ConfigEntryTypeException)
{
  assertType(TypeFloat);

  return(config_setting_get_float(_setting));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator float() const throw(ConfigEntryTypeException)
{
  assertType(TypeFloat);

  // may cause loss of precision:
  return(static_cast<float>(config_setting_get_float(_setting)));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator const char *() const throw(ConfigEntryTypeException)
{
  assertType(TypeString);

  return(config_setting_get_string(_setting));
}

// ---------------------------------------------------------------------------

ConfigEntry::operator String() const throw(ConfigEntryTypeException)
{
  assertType(TypeString);

  const char *s = config_setting_get_string(_setting);

  String str;
  if(s)
    str = s;

  return(str);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(bool value) throw(ConfigEntryTypeException)
{
  assertType(TypeBoolean);

  config_setting_set_bool(_setting, value);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(long value) throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  config_setting_set_int(_setting, value);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(int value) throw(ConfigEntryTypeException)
{
  assertType(TypeInt);

  long cvalue = static_cast<long>(value);

  config_setting_set_int(_setting, cvalue);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(const double &value) throw(ConfigEntryTypeException)
{
  assertType(TypeFloat);

  config_setting_set_float(_setting, value);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(float value) throw(ConfigEntryTypeException)
{
  assertType(TypeFloat);

  double cvalue = static_cast<double>(value);

  config_setting_set_float(_setting, cvalue);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(const char *value) throw(ConfigEntryTypeException)
{
  assertType(TypeString);

  config_setting_set_string(_setting, value);

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator=(const String &value)
  throw(ConfigEntryTypeException)
{
  assertType(TypeString);

  config_setting_set_string(_setting, value.GetData());

  return(*this);
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator[](int i) const
  throw(ConfigEntryTypeException, ConfigEntryNotFoundException)
{
  if((_type != TypeArray) && (_type != TypeGroup) && (_type != TypeList))
    throw ConfigEntryTypeException();

  config_setting_t *setting = config_setting_get_elem(_setting, i);

  if(! setting)
    throw ConfigEntryNotFoundException();

  return(WrapConfigEntry(setting));
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::operator[](const char *key) const
  throw(ConfigEntryTypeException, ConfigEntryNotFoundException)
{
  assertType(TypeGroup);

  config_setting_t *setting = config_setting_get_member(_setting, key);

  if(! setting)
    throw ConfigEntryNotFoundException (key);

  return(WrapConfigEntry(setting));
}

// ---------------------------------------------------------------------------


#define SETTINGS_LOOKUP_NO_EXCEPTIONS(P, T, V, D)			\
  try									\
  {									\
    ConfigEntry &s = operator[](P);					\
    V = (T)s;								\
    return(true);							\
  }									\
  catch(ConfigFileException)						\
  {									\
    V = D;								\
    DBG_WARN ("configuration: '"<<P<<"' doesn't exist [default "<<D<<"]"); \
    return(false);							\
  }

#define SETTINGS_LOOKUP_EXCEPTIONS(P, T, V)		\
  ConfigEntry &s = operator[](P);			\
  V = (T)s;

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, bool &value, bool def) const
  throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, bool, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, long &value, long def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, long, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, unsigned long &value, unsigned long def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, unsigned long, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, int &value, int def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, int, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, unsigned int &value, unsigned int def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, unsigned int, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, double &value, double def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, double, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, float &value, float def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, float, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, const char *&value, const char *def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, const char *, value, def); }

// ---------------------------------------------------------------------------

bool ConfigEntry::GetValue(const char *path, String &value, String def) const throw()
{ SETTINGS_LOOKUP_NO_EXCEPTIONS(path, const char *, value, def); }

// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, bool &value) const throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, bool, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, long &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, long, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, unsigned long &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, unsigned long, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, int &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, int, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, unsigned int &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, unsigned int, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, double &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, double, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, float &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, float, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, const char *&value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, const char *, value); }

// ---------------------------------------------------------------------------

void ConfigEntry::GetValue(const char *path, String &value) const
  throw(ConfigFileException)
{ SETTINGS_LOOKUP_EXCEPTIONS(path, const char *, value); }

// ---------------------------------------------------------------------------

bool ConfigEntry::Exists(const char *name) const throw()
{
  if(_type != TypeGroup)
    return(false);

  config_setting_t *setting = config_setting_get_member(_setting, name);

  return(setting != NULL);
}

// ---------------------------------------------------------------------------

int ConfigEntry::GetLength() const throw()
{
  return(config_setting_length(_setting));
}

// ---------------------------------------------------------------------------

const char * ConfigEntry::GetName() const throw()
{
  return(config_setting_name(_setting));
}
// ---------------------------------------------------------------------------

String ConfigEntry::GetPath() const
{
  String path;

  __constructPath(*this, path);

  return(path);
}

// ---------------------------------------------------------------------------

const ConfigEntry&  ConfigEntry::GetParent() const throw(ConfigEntryNotFoundException)
{
  config_setting_t *setting = config_setting_parent(_setting);

  if(! setting)
    throw ConfigEntryNotFoundException();

  return(WrapConfigEntry(setting));
}

// ---------------------------------------------------------------------------

ConfigEntry& ConfigEntry::GetParent() throw(ConfigEntryNotFoundException)
{
  config_setting_t *setting = config_setting_parent(_setting);

  if(! setting)
    throw ConfigEntryNotFoundException();

  return(WrapConfigEntry(setting));
}

// ---------------------------------------------------------------------------

bool ConfigEntry::IsRoot() const throw()
{
  return(config_setting_is_root(_setting));
}

// ---------------------------------------------------------------------------

int ConfigEntry::GetIndex() const throw()
{
  return(config_setting_index(_setting));
}

// ---------------------------------------------------------------------------

void ConfigEntry::Remove(const char *name)
  throw(ConfigEntryTypeException, ConfigEntryNotFoundException)
{
  assertType(TypeGroup);

  if(! config_setting_remove(_setting, name))
    throw ConfigEntryNotFoundException();
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::Add(const char *name, ConfigEntry::Type type)
  throw(ConfigEntryTypeException, ConfigEntryExistsException)
{
  assertType(TypeGroup);

  int typecode = __toTypeCode(type);

  if(typecode == CONFIG_TYPE_NONE)
    throw ConfigEntryTypeException();

  config_setting_t *setting = config_setting_add(_setting, name, typecode);

  if(! setting)
    throw ConfigEntryExistsException();

  return(WrapConfigEntry(setting));
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::Add(ConfigEntry::Type type) throw(ConfigEntryTypeException)
{
  if((_type != TypeArray) && (_type != TypeList))
    throw ConfigEntryTypeException();

  if(_type == TypeArray)
  {
    if(GetLength() > 0)
    {
      ConfigEntry::Type atype = operator[](0).GetType();
      if(type != atype)
        throw ConfigEntryTypeException();
    }
    else
    {
      if((type != TypeInt) && (type != TypeFloat) && (type != TypeString)
         && (type != TypeBoolean))
        throw ConfigEntryTypeException();
    }
  }

  int typecode = __toTypeCode(type);
  config_setting_t *s = config_setting_add(_setting, NULL, typecode);

  ConfigEntry &ns = WrapConfigEntry(s);

  switch(type)
  {
    case TypeInt:
      ns = 0;
      break;

    case TypeFloat:
      ns = 0.0;
      break;

    case TypeString:
      ns = (char *)NULL;
      break;

    case TypeBoolean:
      ns = false;
      break;

    default:
      // won't happen
      break;
  }

  return(ns);
}

// ---------------------------------------------------------------------------

void ConfigEntry::assertType(ConfigEntry::Type type) const throw(ConfigEntryTypeException)
{
  if(type != _type)
  {
    if(!(IsNumber() && config_get_auto_convert(_setting->config)
         && ((type == TypeInt) || (type == TypeFloat))))
      throw ConfigEntryTypeException();
  }
}

// ---------------------------------------------------------------------------

ConfigEntry & ConfigEntry::WrapConfigEntry(config_setting_t *s)
{
  ConfigEntry *setting = NULL;

  void *hook = config_setting_get_hook(s);
  if(! hook)
  {
    setting = new ConfigEntry(s);
    config_setting_set_hook(s, reinterpret_cast<void *>(setting));
  }
  else
    setting = reinterpret_cast<ConfigEntry *>(hook);

  return(*setting);
}

// ---------------------------------------------------------------------------
// eof
