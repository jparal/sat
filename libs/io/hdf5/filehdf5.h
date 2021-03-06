/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   filexdfm.h
 * @brief  HDF5 file writer
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_FILEXDFM_H__
#define __SAT_FILEXDFM_H__

#include "io/misc/iofile.h"
#include "simul/field/field.h"
#include "simul/field/mesh.h"

#ifdef HAVE_HDF5
#define H5_USE_16_API 1
#include <hdf5.h>
#include "hdf5types.h"
#endif

/// @addtogroup io_hdf5
/// @{

/**
 * @brief HDF5 file writer
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/08, @jparal}
 * @revmessg{add Write function for Vector fields}
 */
class HDF5File : public IOFile
{
public:
  /// Constructor
  HDF5File ()
    : _file(0), IOFile () {}

  HDF5File (const char *fname, IOFile::Flags flags = 0)
    : _file(0), IOFile ()
  { Open (fname, flags); }

  ~HDF5File ()
  { Close(); }

  virtual void Open (const char *fname, IOFile::Flags flags = 0);
  virtual void Close ();

  template<class T, int D>
  void Write (const Field<T,D> &fld, const char *tag);

  template<class T, int R, int D>
  void Write (const Field<Vector<T,R>,D> &fld, const char *tag);

  template<class T>
  void Write (const Array<T> &arr, const char *tag);

  template<class T, int D>
  void Read (Field<T,D> &fld, const char *tag);

  template<class T, int R, int D>
  void Read (Field<Vector<T,R>,D> &fld, const char *tag);

private:
  template<class T>
  void ReceiveData (T *data, size_t len, int iprc);
  template<class T>
  void SendData (T *data, size_t len);

  template<class T, class T2, int D>
  void WriteChunk (T *data, const Field<T2,D> &fld, const char *tag,
		   int iprc, int rank);
  template<class T, int D>
  void CopyData (T *data, const Field<T,D> &fld);
  template<class T, int R, int D>
  void CopyData (T *data, const Field<Vector<T,R>,D> &fld, int rank);

  template<class T, int D>
  Domain<D> GetWritableDomain (const Field<T,D> &fld);

  hid_t _file;
};

/// @}

#endif /* __SAT_FILEXDFM_H__ */
