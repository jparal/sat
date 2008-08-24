/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filestw.h
 * @brief  Wrapper around STW file
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FILESTW_H__
#define __SAT_FILESTW_H__

#include <iostream>
#include <fstream>
#include "math/misc/vector.h"
#include "io/misc/gzstream.h"

#define STWFILE_VALUES_PER_LINE 5

/** @addtogroup io_stw
 *  @{
 */

struct File
{
  enum Ios
  {
    In  = 1 << 0,
    Out = 1 << 1,
    App = 1 << 2,
    Gz  = 1 << 3,
  };
};

/**
 * @brief Wrapper around STW file
 * The purpose of this class is to have a mechanism which distinguish between
 * standard type (float, double) and a Vector type, as well as, hide the
 * details of whether we have zlib or not.
 *
 * @revision{1.0}
 * @reventry{2008-06-09, @jparal}
 * @revmessg{Initial version}
 */
template<int D>
class StwFile
{
public:
  /// Constructor
  StwFile ();
  /// Destructor
  ~StwFile () { Close (); };

  void Open (const char *name, int mode = File::Out | File::Gz)
  { Open ("", name, mode); }

  void Open (const char *sensor, const char *name,
	     int mode = File::Out | File::Gz);

  /// You should call this function prior any call of Write
  template<int R>
  void WriteHeader (const Vector<int,R> &rank);

  template<class T>
  void Write (const T &val);

  template<class T>
  void Write (const Vector<T,D> &val);

  /// You should call this function prior any call of Write
  template<int R>
  void ReadHeader (Vector<int,R> &rank);

  template<class T>
  void Read (T &val);

  template<class T>
  void Read (Vector<T,D> &val);

  void Close ();

private:

  template<class T>
  void Write (const T &val, int is);

  void Open (const char *sensor, const char *comp, const char *name,
  	     int mode, int is);

  unsigned int _cnt;
  int _mode;
  std::ostream *_ofs[D];
  std::istream *_ifs[D];
};

/** @} */

#include "filestw.cpp"

#endif /* __SAT_FILESTW_H__ */
