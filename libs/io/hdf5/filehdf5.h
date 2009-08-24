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

/** @addtogroup io_hdf5
 *  @{
 */

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
  HDF5File () : IOFile () {}

  template<class T, int D>
  void Write (const Field<T,D> &fld, Centring center,
	      const char *tag, const char *fname);

  template<class T, int R, int D>
  void Write (const Field<Vector<T,R>,D> &fld, Centring center,
	      const char *tag, const char *fname);

  template<class T>
  void Write (const Array<T> &arr, const char *tag, const char *fname,
	      bool append = false);

  template<class T, int D>
  void Read (Field<T,D> &fld, Centring center,
	     const char *tag, const char *fname);

  template<class T, int R, int D>
  void Read (Field<Vector<T,R>,D> &fld, Centring center,
	     const char *tag, const char *fname);
};

/** @} */

#endif /* __SAT_FILEXDFM_H__ */
