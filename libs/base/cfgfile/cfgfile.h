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

#ifndef __libconfig_hpp
#define __libconfig_hpp

#include "cfgcore.h"
#include "satmath.h"

template<class T, int D> class Vector;

class LIBCONFIG_API ConfigFileException
{
public:
  ConfigFileException (const char *msg = "")
    : _msg(msg) {}
  const char* GetMessage () const
  { return _msg; }
private:
  const char *_msg;
};
class LIBCONFIG_API ConfigEntryTypeException : public ConfigFileException { };
class LIBCONFIG_API ConfigEntryNotFoundException : public ConfigFileException
{
public:
  ConfigEntryNotFoundException (const char *msg = "")
    : ConfigFileException (msg) {}
};
class LIBCONFIG_API ConfigEntryExistsException : public ConfigFileException { };
class LIBCONFIG_API FileIOException : public ConfigFileException { };

// using namespace std;

class LIBCONFIG_API ParseException : public ConfigFileException
{
  friend class ConfigFile;

private:

  int _line;
  const char *_error;

  ParseException(int line, const char *error)
    : _line(line), _error(error) {}

public:

  virtual ~ParseException() { }

  inline int GetLine() throw() { return(_line); }
  inline const char *GetError() throw() { return(_error); }
};

class LIBCONFIG_API ConfigEntry
{
  friend class ConfigFile;

public:

  enum Type
  {
    TypeNone = 0,
    // scalar types
    TypeInt,
    TypeFloat,
    TypeString,
      TypeBoolean,
    // aggregate types
    TypeGroup,
    TypeArray,
    TypeList
  };

  enum Format
  {
    FormatDefault = 0,
    FormatHex = 1
  };

private:

  config_setting_t *_setting;
  Type _type;
  Format _format;

  ConfigEntry(config_setting_t *setting);

  void assertType(Type type) const
    throw(ConfigEntryTypeException);
  static ConfigEntry & WrapConfigEntry(config_setting_t *setting);

  ConfigEntry(const ConfigEntry& other); // not supported
  ConfigEntry& operator=(const ConfigEntry& other); // not supported

public:

  virtual ~ConfigEntry() throw();

  inline Type GetType() const throw() { return(_type); }

  inline Format GetFormat() const throw() { return(_format); }
  void SetFormat(Format format) throw();

  operator bool() const throw(ConfigEntryTypeException);
  operator long() const throw(ConfigEntryTypeException);
  operator unsigned long() const throw(ConfigEntryTypeException);
  operator int() const throw(ConfigEntryTypeException);
  operator unsigned int() const throw(ConfigEntryTypeException);
  operator double() const throw(ConfigEntryTypeException);
  operator float() const throw(ConfigEntryTypeException);
  operator const char *() const throw(ConfigEntryTypeException);
  operator String() const throw(ConfigEntryTypeException);

  ConfigEntry & operator=(bool value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(long value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(int value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(const double &value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(float value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(const char *value) throw(ConfigEntryTypeException);
  ConfigEntry & operator=(const String &value) throw(ConfigEntryTypeException);

  ConfigEntry & operator[](const char * key) const
    throw(ConfigEntryTypeException, ConfigEntryNotFoundException);

  inline ConfigEntry & operator[](const String & key) const
    throw(ConfigEntryTypeException, ConfigEntryNotFoundException)
  { return(operator[](key.GetData())); }

  ConfigEntry & operator[](int index) const
    throw(ConfigEntryTypeException, ConfigEntryNotFoundException);

  bool GetValue(const char *path, bool &value, bool def) const throw();
  bool GetValue(const char *path, long &value, long def) const throw();
  bool GetValue(const char *path, unsigned long &value, unsigned long def) const throw();
  bool GetValue(const char *path, int &value, int def) const throw();
  bool GetValue(const char *path, unsigned int &value, unsigned int def) const throw();
  bool GetValue(const char *path, double &value, double def) const throw();
  bool GetValue(const char *path, float &value, float def) const throw();
  bool GetValue(const char *path, const char *&value, const char *def) const throw();
  bool GetValue(const char *path, String &value, String def) const throw();
  template<class T, int D>
  bool GetValue(const char *path, Vector<T,D> &value, const Vector<T,D> &def) const throw();

  inline bool GetValue(const String &path, bool &value, bool def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, long &value, long def) const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, unsigned long &value, unsigned long def)
    const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, int &value, int def) const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, unsigned int &value, unsigned int def)
    const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, double &value, double def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, float &value, float def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, const char *&value, const char *def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, String &value, String def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  template<class T, int D>
  inline bool GetValue(const String &path, Vector<T,D> &value,
  		       const Vector<T,D> &def) const throw()
  { return(GetValue(path.GetData(), value, def)); }

  /*******************************/

  void GetValue(const char *path, bool &value) const throw(ConfigFileException);
  void GetValue(const char *path, long &value) const throw(ConfigFileException);
  void GetValue(const char *path, unsigned long &value) const throw(ConfigFileException);
  void GetValue(const char *path, int &value) const throw(ConfigFileException);
  void GetValue(const char *path, unsigned int &value) const throw(ConfigFileException);
  void GetValue(const char *path, double &value) const throw(ConfigFileException);
  void GetValue(const char *path, float &value) const throw(ConfigFileException);
  void GetValue(const char *path, const char *&value) const throw(ConfigFileException);
  void GetValue(const char *path, String &value) const throw(ConfigFileException);
  template<class T, int D>
  void GetValue(const char *path, Vector<T,D> &value) const throw(ConfigFileException);
  template<class T, int D>
  void GetValue(int pos, Vector<T,D> &value) const throw(ConfigFileException);

  inline void GetValue(const String &path, bool &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, long &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, unsigned long &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, int &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, unsigned int &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, double &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, float &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, const char *&value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, String &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  template<class T, int D>
  inline void GetValue(const String &path, Vector<T,D> &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  void Remove(const char *name)
    throw(ConfigEntryTypeException, ConfigEntryNotFoundException);

  inline void Remove(const String & name)
    throw(ConfigEntryTypeException, ConfigEntryNotFoundException)
  { Remove(name.GetData()); }

  inline ConfigEntry & Add(const String & name, Type type)
    throw(ConfigEntryTypeException, ConfigEntryExistsException)
  { return(Add(name.GetData(), type)); }

  ConfigEntry & Add(const char *name, Type type)
    throw(ConfigEntryTypeException, ConfigEntryExistsException);

  ConfigEntry & Add(Type type)
    throw(ConfigEntryTypeException);

  inline bool Exists(const String & name) const throw()
  { return(Exists(name.GetData())); }

  bool Exists(const char *name) const throw();

  int GetLength() const throw();
  const char *GetName() const throw();

  String GetPath() const;
  int GetIndex() const throw();

  const ConfigEntry& GetParent() const throw(ConfigEntryNotFoundException);
  ConfigEntry & GetParent() throw(ConfigEntryNotFoundException);

  bool IsRoot() const throw();

  inline bool IsGroup() const throw()
  { return(_type == TypeGroup); }

  inline bool IsArray() const throw()
  { return(_type == TypeArray); }

  inline bool IsList() const throw()
  { return(_type == TypeList); }

  inline bool IsAggregate() const throw()
  { return(_type >= TypeGroup); }

  inline bool IsScalar() const throw()
  { return((_type > TypeNone) && (_type < TypeGroup)); }

  inline bool IsNumber() const throw()
  { return((_type == TypeInt) || (_type == TypeFloat)); }

  inline unsigned int GetSourceLine() const throw()
  { return(config_setting_source_line(_setting)); }
};

class LIBCONFIG_API ConfigFile
{
private:

  config_t _config;

  static void ConfigFileDestructor(void *arg);
  ConfigFile(const ConfigFile& other); // not supported
  ConfigFile& operator=(const ConfigFile& other); // not supported

public:

  ConfigFile();

  virtual ~ConfigFile();

  void SetAutoConvert(bool flag = true);
  bool GetAutoConvert() const;

  void Read(FILE *stream) throw(ParseException);
  void Write(FILE *stream) const;

  void ReadFile(const char *filename) throw(FileIOException, ParseException);
  void WriteFile(const char *filename) throw(FileIOException);

  inline ConfigEntry & GetEntry(const String &path) const
    throw(ConfigEntryNotFoundException)
  { return(GetEntry(path.GetData())); }

  ConfigEntry & GetEntry(const char *path) const
    throw(ConfigEntryNotFoundException);

  inline bool Exists(const String & path) const throw()
  { return(Exists(path.GetData())); }

  bool Exists(const char *path) const throw();

  bool GetValue(const char *path, bool &value, bool def) const throw();
  bool GetValue(const char *path, long &value, long def) const throw();
  bool GetValue(const char *path, unsigned long &value, unsigned long def) const throw();
  bool GetValue(const char *path, int &value, int def) const throw();
  bool GetValue(const char *path, unsigned int &value, unsigned int def) const throw();
  bool GetValue(const char *path, double &value, double def) const throw();
  bool GetValue(const char *path, float &value, float def) const throw();
  bool GetValue(const char *path, const char *&value, const char *def) const throw();
  bool GetValue(const char *path, String &value, String def) const throw();
  template<class T, int D>
  bool GetValue(const char *path, Vector<T,D> &value, const Vector<T,D> &def) const throw();

  inline bool GetValue(const String &path, bool &value, bool def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, long &value, long def) const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, unsigned long &value, unsigned long def)
    const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, int &value, int def) const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, unsigned int &value, unsigned int def)
    const throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, double &value, double def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, float &value, float def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, const char *&value, const char *def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  inline bool GetValue(const String &path, String &value, String def) const
    throw()
  { return(GetValue(path.GetData(), value, def)); }

  template<class T, int D>
  inline bool GetValue(const String &path, Vector<T,D> &value, const Vector<T,D> &def)
    const throw()
  { return(GetValue(path.GetData(), value, def)); }

  /*******************************/

  void GetValue(const char *path, bool &value) const throw(ConfigFileException);
  void GetValue(const char *path, long &value) const throw(ConfigFileException);
  void GetValue(const char *path, unsigned long &value) const throw(ConfigFileException);
  void GetValue(const char *path, int &value) const throw(ConfigFileException);
  void GetValue(const char *path, unsigned int &value) const throw(ConfigFileException);
  void GetValue(const char *path, double &value) const throw(ConfigFileException);
  void GetValue(const char *path, float &value) const throw(ConfigFileException);
  void GetValue(const char *path, const char *&value) const throw(ConfigFileException);
  void GetValue(const char *path, String &value) const throw(ConfigFileException);
  template<class T, int D>
  void GetValue(const char *path, Vector<T,D> &value) const throw(ConfigFileException);

  inline void GetValue(const String &path, bool &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, long &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, unsigned long &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, int &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, unsigned int &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, double &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, float &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, const char *&value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  inline void GetValue(const String &path, String &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  template<class T, int D>
  inline void GetValue(const String &path, Vector<T,D> &value) const
    throw(ConfigFileException)
  { return(GetValue(path.GetData(), value)); }

  ConfigEntry & GetRoot() const;
};

#include "cfgfile.cpp"

#endif // __libconfig_hpp
