/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   streammpi.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-06-05, @jparal}
 * @revmessg{Initial version}
 */

#include "mpitype.h"

template<class T>
MpiIStream<T>::MpiIStream (int src, int tag, Mpi::Comm comm)
  : _proc(src), _tag(tag), _comm(comm), _len(MPISTREAM_BUFF_SIZE),
    _lastgrp(false), _cnt(0)
{
  //  _tag += 2;
  _last = &_buff[MPISTREAM_BUFF_SIZE];
  _curr = _last;
}

template<class T>
MpiIStream<T>::~MpiIStream ()
{
  if (!_lastgrp)
    Recv (_buff, &_curr);
}

template<class T>
MpiOStream<T>::MpiOStream (int dest, int tag, Mpi::Comm comm)
  : _proc(dest), _tag(tag), _comm(comm),
    _len(MPISTREAM_BUFF_SIZE), _cnt(0)
{
  //  _tag += 2;
  _last = &_buff[MPISTREAM_BUFF_SIZE];
  _curr = _buff;
}

template<class T>
MpiOStream<T>::~MpiOStream ()
{
  Flush (true);
}

template<class T>
void MpiOStream<T>::Flush (bool last)
{
  Send (_buff, &_curr, last);
}

template<class T>
void MpiIStream<T>::Recv (T *buff, T **curr)
{
#ifdef HAVE_MPI
  Mpi::SetComm (_comm);
  int nrecv = 2;
  int recv[2];
  Mpi::Recv ((int*)recv, nrecv, _proc, _tag);
  _cnt = recv[0];
  _lastgrp = (recv[1] > 0);

  if (_cnt > 0)
    Mpi::Recv (buff, _cnt, _proc, _tag+1);

  *curr=buff;
#endif // HAVE_MPI
}

template<class T>
void MpiOStream<T>::Send (T *buff, T **curr, bool last)
{
#ifdef HAVE_MPI
  Mpi::SetComm (_comm);
  int nsend = 2;
  int send[2];
  send[0] = _cnt;
  send[1] = (last ? 1 : 0);
  Mpi::Send ((int*)send, nsend, _proc, _tag);

  if (_cnt > 0)
    Mpi::Send (buff, _cnt, _proc, _tag+1);

  _cnt = 0;
  *curr = buff;
#endif // HAVE_MPI
}

template<class T> inline
MpiIStream<T>& MpiIStream<T>::operator>> (T &val)
{
  if (_curr==_last || _cnt == 0)
    Recv (_buff, &_curr);

  SAT_DBG_ASSERT (_cnt > 0);
  val = *_curr++;
  _cnt -= MpiType<T>::Rank ();

  return *this;
}

template<class T> inline
MpiOStream<T>& MpiOStream<T>::operator<< (T val)
{
  *_curr++ = val;
  _cnt += MpiType<T>::Rank ();
  if (_curr == _last)
    Send (_buff, &_curr);

  return *this;
}
