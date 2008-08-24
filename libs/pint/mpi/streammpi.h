/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   streammpi.h
 * @brief  MPI Stream for poin-to-point communications
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_STREAMMPI_H__
#define __SAT_STREAMMPI_H__

#include "wrap.h"

/** @addtogroup pint_mpi
 *  @{
 */

/**
 * Define size of the buffers allocated in IOStream class
 */
#define MPISTREAM_BUFF_SIZE 512

/**
 * @brief MPI Input Stream for poin-to-point communications
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 * @reventry{2008/09, @jparal}
 * @revmessg{In the certain situation MpiOStream send the message but
 *          MpiIStream wont accept it in the case we didn't call appropriate
 *          operator>>. We must try to accept the message in the destructor of
 *          MpiIStream when _lastgrp is false (that means we still expect some
 *          data to come).}
 */
template<class T>
class MpiIStream
{
public:
  /**
   * Constructor
   *
   * @param[in] dest processor ID
   * @param[in,out] tag message tag (the variable of the tag is updated
   *       internally by 2 since we require two tags for communication)
   * @param[in] comm communicator
   */
  MpiIStream (int src, int tag, Mpi::Comm comm = Mpi::COMM_WORLD);

  /// Destructor
  ~MpiIStream ();

  /// return true is there are data left in the buffer
  bool HasNext ()
  {
    if (!_lastgrp && (_cnt == 0))
      Recv (_buff, &_curr);

    return !(_lastgrp && (_cnt == 0));
  }

  MpiIStream& operator>> (T &val);

protected:
  void Recv (T *buff, T **curr);

  T *_curr;
  T *_last;
  T _buff[MPISTREAM_BUFF_SIZE];

  int _cnt; /**< Number of elements in the buffer */
  bool _lastgrp; ///< last group of _cnt values?
  int _len; /**< Length of the buffers */
  int _proc; ///< Process ID we are communicating with
  int _tag;  ///< Tag of the message
  Mpi::Comm _comm; ///< Communicator
};

/**
 * @brief MPI Output Stream for poin-to-point communications
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */
template<class T>
class MpiOStream
{
public:
  /**
   * Constructor
   *
   * @param[in] dest processor ID
   * @param[in,out] tag message tag (the variable of the tag is updated
   *       internally by 2 since we require two tags for communication)
   * @param[in] comm communicator
   */
  MpiOStream (int dest, int tag, Mpi::Comm comm = Mpi::COMM_WORLD);

  /// destructor
  ~MpiOStream ();

  /**
   * flush the buffer
   *
   * @param last is it the last batch of the data
   */
  void Flush (bool last);

  MpiOStream& operator<< (T val);

private:
  void Send (T *buff, T **curr, bool last = false);

  T *_curr;
  T *_last;
  T _buff[MPISTREAM_BUFF_SIZE];

  int _cnt; /**< Number of elements in the buffer */
  int _len; /**< Length of the buffers */
  int _proc; ///< Process ID we are communicating with
  int _tag;  ///< Tag of the message
  Mpi::Comm _comm; ///< Communicator
};

#include "streammpi.cpp"

/** @} */

#endif /* __SAT_STREAMMPI_H__ */
