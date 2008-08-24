/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wrap.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#include "satsysdef.h"
#include "base/sys/inline.h"
#include "base/sys/stdfuncs.h"

#ifdef HAVE_MPI
#include "mpitype.h"
#endif

SAT_INLINE
void Mpi::SetComm (Mpi::Comm comm)
{
  s_comm = comm;
}

SAT_INLINE
Mpi::Comm Mpi::GetComm ()
{
  return s_comm;
}

SAT_INLINE
int Mpi::Rank ()
{
  int myid = 0;
#ifdef HAVE_MPI
  MPI_Comm_rank (s_comm, &myid);
#endif
  return myid;
}

SAT_INLINE
int Mpi::Nodes ()
{
  int nodes = 1;
#ifdef HAVE_MPI
  MPI_Comm_size (s_comm, &nodes);
#endif
  return nodes;
}

SAT_INLINE
void Mpi::UpdateOutflow (const int nmsg, const int nbyte)
{
   s_noutmsg  += nmsg;
   s_noutbyte += nbyte;
}

SAT_INLINE
void Mpi::UpdateInflow (const int nmsg, const int nbyte)
{
   s_ninmsg  += nmsg;
   s_ninbyte += nbyte;
}

SAT_INLINE
int Mpi::OutflowMessages ()
{
   return s_noutmsg;
}

SAT_INLINE
int Mpi::OutflowBytes ()
{
   return s_noutbyte;
}

SAT_INLINE
int Mpi::InflowMessages ()
{
   return s_ninmsg;
}

SAT_INLINE
int Mpi::InflowBytes ()
{
   return s_ninbyte;
}

template <class T> SAT_INLINE
void Mpi::SumReduce (T *data, int ndata)
{
#ifdef HAVE_MPI
  Reduce (MPI_SUM, data, ndata, NULL);
#else
  NULL_USE(data);
  NULL_USE(ndata);
#endif
}

template <class T> SAT_INLINE
void Mpi::MinReduce (T *data, int ndata, int *who)
{
#ifdef HAVE_MPI
  Reduce (MPI_MIN, data, ndata, who);
#else
  NULL_USE (data);
  NULL_USE (ndata);
  NULL_USE (who);
#endif
}

template <class T> SAT_INLINE
void Mpi::MaxReduce (T *data, int ndata, int *who)
{
#ifdef HAVE_MPI
  Reduce (MPI_MAX, data, ndata, who);
#else
  NULL_USE (data);
  NULL_USE (ndata);
  NULL_USE (who);
#endif
}

template <class T> SAT_INLINE
void Mpi::SumReduceOne (T *data, int ndata, int root, int *who)
{
#ifdef HAVE_MPI
  ReduceOne (MPI_SUM, data, ndata, root, who);
#else
  NULL_USE (data);
  NULL_USE (ndata);
  NULL_USE (root);
  NULL_USE (who);
#endif
}

template <class T> SAT_INLINE
void Mpi::Bcast (T *data, int ndata, int root)
{
#ifdef HAVE_MPI
  if (Nodes () <= 1)
    return;

  MPI_Datatype type = MpiType<T>::GetID ();

  MPI_Bcast (data, ndata, type, root, s_comm);

  const int tree = TreeDepth ();
  if (Rank () == root)
    UpdateOutflow (tree, ndata * sizeof(T));
  else
    UpdateInflow (tree, ndata * sizeof(T));

#else
  NULL_USE (data);
  NULL_USE (ndata);
  NULL_USE (root);
#endif
}


template <class T> SAT_INLINE
void Mpi::Send (const T *data, int ndata, int to, int tag, bool unknownlen)
{
#ifdef HAVE_MPI
  tag = (tag >= 0) ? tag : 0;
  int size = ndata;
  if (unknownlen)
  {
    MPI_Send (&size, 1, MPI_INT, to, tag, s_comm);
    UpdateOutflow (TreeDepth (), sizeof(int));
  }

  MPI_Datatype type = MpiType<T>::GetID ();
  MPI_Send((void*)data, ndata, type, to, tag, s_comm);

  UpdateOutflow (TreeDepth (), ndata * sizeof(T));
#endif
}

template <class T> SAT_INLINE
void Mpi::Recv (T *data, int &ndata, int from, int tag, bool unknownlen)
{
#ifdef HAVE_MPI
  MPI_Status status;

  tag = (tag >= 0) ? tag : 0;
  if (from < 0)
  {
    tag  = MPI_ANY_TAG;
    from = MPI_ANY_SOURCE;
  }

  if (unknownlen)
  {
    MPI_Recv (&ndata, 1, MPI_INT, from, tag, s_comm, &status);
    UpdateInflow (TreeDepth(), sizeof(int));
  }
  MPI_Datatype type = MpiType<T>::GetID ();
  MPI_Recv((void*)data, ndata, type, from, tag, s_comm, &status);
  UpdateInflow (TreeDepth(), ndata * sizeof(T));
#endif
}

template <class T> SAT_INLINE
void Mpi::Gather (T in, T *out)
{
#ifdef HAVE_MPI
  MPI_Datatype type = MpiType<T>::GetID ();
  MPI_Allgather(&in, 1, type, out, 1, type, s_comm);
  const int tree = TreeDepth ();
  UpdateInflow (tree, Mpi::Nodes () * sizeof(T));
  UpdateOutflow (tree, sizeof(T));
#else
  NULL_USE (in);
  NULL_USE (out);
#endif
}

template <class T> SAT_INLINE
void Mpi::Gather (const T *data, int ndata, T *out, int nout)
{
#ifdef HAVE_MPI
  int np = Mpi::Nodes ();
  SAT_ALLOCA (int, counts, np);
  SAT_ALLOCA (int, disps, np);

  /* figure out where where each processor's input will be placed */
  Mpi::Gather (ndata, counts);

  disps[0] = 0;
  for (int p = 1; p < np; ++p)
    disps[p] = disps[p-1] + counts[p-1];

  /* verify that the x_out array is the appropriate size! */
  int cnt = 0;
  for (int x = 0; x < np; ++x)
    cnt += counts[x];

  SAT_ASSERT_MSG (cnt != nout, "Mpi::Gather error: incorrect number elems");

  MPI_Datatype type = MpiType<T>::GetID ();
  MPI_Allgatherv ((void*)data, ndata, type,
		  (void*)out, counts, disps, type,
		  s_comm);

  const int tree = TreeDepth ();
  UpdateInflow (tree, cnt * sizeof(T));
  UpdateOutflow (tree, ndata * sizeof(T));

#else
  NULL_USE (data);
  NULL_USE (ndata);
  NULL_USE (out);
  NULL_USE (nout);
#endif
}


/*************************************************************************/
#ifdef HAVE_MPI
template <class T> SAT_INLINE
void Mpi::Reduce (MPI_Op op, T *data, int ndata, int *who)
{
  if (Nodes () <= 1)
    return;

  size_t size;
  if (who == NULL)
  {
    size = sizeof(T);
    MPI_Datatype type = MpiType<T>::GetID ();
    T *buff = new T[ndata];

    MPI_Allreduce (data, buff, ndata, type, op, s_comm);
    memcpy (data, buff, ndata * size);
    delete[] buff;
  }
  else
  {
    typedef typename MpiType<T>::MpiTypeInt TypeInt;
    TypeInt *buff = new TypeInt[ndata];

    size = sizeof(TypeInt);
    MPI_Datatype type = MpiType<TypeInt>::GetID ();

    for ( int i=0; i<ndata; ++i )
    {
      buff[i].d = data[i];
      buff[i].i = Rank ();
    }

    MPI_Allreduce (buff, buff, ndata, type, op, s_comm);

    for ( int i=0; i<ndata; ++i )
    {
      data[i] = buff[i].d;
      who [i] = buff[i].i;
    }
  }
  const int tree = TreeDepth ();
  UpdateOutflow (tree, ndata * size);
  UpdateInflow (tree, ndata * size);
}
#endif

#ifdef HAVE_MPI
template <class T> SAT_INLINE
void Mpi::ReduceOne (MPI_Op op, T *data, int ndata, int root, int *who)
{
  if (Nodes () <= 1)
    return;

  size_t size;
  if (who == NULL)
  {
    size = sizeof(T);
    MPI_Datatype type = MpiType<T>::GetID ();
    T *buff = new T[ndata];

    MPI_Reduce(data, buff, ndata, type, op, root, s_comm);
    memcpy (data, buff, ndata * size);
    delete[] buff;
  }
  else
  {
    typedef typename MpiType<T>::MpiTypeInt TypeInt;
    TypeInt *buff = new TypeInt[ndata];

    size = sizeof(TypeInt);
    MPI_Datatype type = MpiType<TypeInt>::GetID ();

    // Copy to the buffer
    for ( int i=0; i<ndata; ++i )
    {
      buff[i].d = data[i];
      buff[i].i = Rank ();
    }

    MPI_Reduce(buff, buff, ndata, type, op, root, s_comm);

    // Copy from the buffer
    for ( int i=0; i<ndata; ++i )
    {
      data[i] = buff[i].d;
      who [i] = buff[i].i;
    }
  }
  const int tree = TreeDepth ();
  if (Rank() == root)
    UpdateOutflow (tree, ndata * sizeof(T));
  else
    UpdateInflow (tree, ndata * sizeof(T));
}

#endif
