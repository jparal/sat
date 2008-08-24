/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   wrap.h
 * @brief  Simple utility class for wrapping of MPI
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007-03-06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_WRAP_H__
#define __SAT_WRAP_H__

#include "satconfig.h"
#include "mpihdr.h"
#include "base/sys/stdhdrs.h"

/** @addtogroup pint_mpi
 *  @{
 */

/**
 * Class MPI groups common MPI routines into one globally-accessible location.
 * It provides small, simple routines that are common in MPI code.  In some
 * cases, the calling syntax has been simplified for convenience.  Moreover,
 * there is no reason to include the preprocessor ifdef/endif guards around
 * these calls, since the MPI libraries are not called in these routines if the
 * MPI libraries are not being used (e.g., when writing serial code).
 *
 * Note that this class is a utility class to group function calls in one name
 * space (all calls are to static functions).  Thus, you should never attempt
 * to instantiate a class of type MPI; simply call the functions as static
 * functions using the Mpi::function(...) syntax.
 */
struct Mpi
{
  // MPI Types
#ifdef HAVE_MPI
   typedef MPI_Comm Comm;
   typedef MPI_Group Group;
   typedef MPI_Request Request;
   typedef MPI_Status Status;
#else
   typedef int Comm;
   typedef int Group;
   typedef int Request;
   typedef int Status;
#endif

  /// @{
  /// @name MPI constants

  /// COMM_WORLD
  static Comm COMM_WORLD;
  /// COMM_NULL
  static Comm COMM_NULL;

  /// @}

  /// @{
  /// @name Comunication

  /**
   * Perform a global barrier across all processors.
   */
  static void Barrier ();

  /**
   * Perform an array sum reduction across all nodes.  Each processor
   * contributes an array of values of type T, and the element-wise maximum
   * is returned in the same array.
   */
  template <class T>
  static void SumReduce (T *data, int ndata = 1);

  /**
   * Perform an array min reduction across all nodes.  Each processor
   * contributes an array of values of type T, and the element-wise maximum
   * is returned in the same array.
   *
   * If a 'who' argument is provided, it will set the array to the rank of
   * process holding the maximum value. The size of the supplied 'who' array
   * should be n.
   */
  template <class T>
  static void MinReduce (T *data, int ndata = 1, int *who = NULL);

  /**
   * Perform an array max reduction across all nodes.  Each processor
   * contributes an array of values of type T, and the element-wise maximum
   * is returned in the same array.
   *
   * If a 'who' argument is provided, it will set the array to the rank of
   * process holding the maximum value. The size of the supplied 'who' array
   * should be n.
   */
  template <class T>
  static void MaxReduce (T *data, int ndata = 1, int *who = NULL);

  /**
   * Perform an all-to-one sum reduction on an integer array.  The final result
   * is only available on the root processor.
   *
   * \todo Rework handling of the buffer since in some implementations sending
   * and recieving buffer has to differ.
   */
  template <class T>
  static void SumReduceOne (T *data, int ndata = 1,
			    int root = 0, int *who = NULL);

  /**
   * Broadcast T array from specified root processor to all other processors.
   * For the root processor, "array" and "length" are treated as const.
   */
  template <class T>
  static void Bcast (T *data, int ndata, int root);

  /**
   * @brief This function sends an MPI message with an type \e T array to
   * another processor.
   *
   * If the receiving processor knows in advance the length of the array, use
   * "unknownlen = false;" otherwise, this processor will first send the
   * length of the array, then send the data.  This call must be paired with a
   * matching call to Mpi::Recv only!
   *
   * @param data Pointer to integer array buffer with length integers.
   * @param ndata Number of integers in buf that we want to send.
   * @param to Receiving processor number.
   * @param unknownlen Optional boolean argument specifiying if we first need
   * to send a message with the array size. Default value is true.
   * @param tag Optional integer argument specifying an integer tag to be sent
   * with this message.  Default tag is 0.
   */
  template <class T>
  static void Send (const T *data, int ndata, int to,
		    int tag = -1, bool unknownlen = false);

  /**
   * @brief This function receives an MPI message with an type \e T array from
   * another processor.
   *
   * If this processor knows in advance the length of the array, use
   * "unknownlen = false;" otherwise, the sending processor will first send the
   * length of the array, then send the data.  This call must be paired with a
   * matching call to MPI::send.
   *
   * @param data Pointer to integer array buffer with capacity of length
   * integers.
   * @param ndata Maximum number of integers that can be stored in buf (not
   * number of bytes !!).
   * @param from Processor number of sender. If \e from is less then 0
   * then \e MPI_ANY_SOURCE and \e MPI_ANY_TAG will be used.
   * @param unknownlen Optional boolean argument specifiying if we first need
   * to send a message to determine the array size. Default value is true. Then
   * recieved number will be in \e ndata.
   * @param tag Optional integer argument specifying a tag which must be
   * matched by the tag of the incoming message. Default tag is 0.
   */
  template <class T>
  static void Recv (T *data, int &ndata, int from,
                    int tag = -1, bool unknownlen = false);

  /**
   * @brief Simplified version for gather only one value from each node in a
   * communication group.
   *
   * @code
   *   T val = ...;
   *   int nodes = Mpi::Nodes ();
   *   T *out = new T[nodes];
   *   Mpi::Gather (val, out);
   * @endcode
   *
   * @param in value to send
   * @param out array of values from each node
   */
  template <class T>
  static void Gather (T in, T *out);

  /**
   * Each processor sends an array of type \e T to all other processors; each
   * processor's array may differ in length.  The \e out array must be
   * pre-allocated to the correct length (this is a bit cumbersome, but is
   * necessary to avoid the Gather function from allocating memory that is
   * freed elsewhere).  To properly preallocate memory, before calling this
   * method and figure out the sizes, call:
   *
   * @code
   *   total = ndata;
   *   Mpi::SumReduce (&total);
   *   SAT_ALLOCA (int, neach, total);
   *   Mpi::Gather (&ndata, 1, neach, total);
   * @endcode
   *
   * and then you should have \e neach[iproc] number of elements with total
   * in \e total
   *
   * @param data Array of data to
   * @param ndata Number of alements in \e data (not number of bytes !!)
   * @param out output array
   * @param nout number of elements in \e out (not number of bytes !!)
   */
  template <class T>
  static void Gather (const T *data, int ndata, T *out, int nout);

  /** @} */


  /** @{ Misc */
  /**
   * Set boolean flag indicating whether exit or abort is called when running
   * with one processor.  Calling this function influences the behavior of
   * calls to Mpi::Abort().  By default, the flag is true meaning that abort()
   * will be called.  Passing false means exit(-1) will be called.
   */
  static void AbortOrExit (bool abort = true);

  /**
   * Call MPI_Abort or exit depending on whether running with one or more
   * processes and value set by function above, if called.  The default is to
   * call exit(-1) if running with one processor and to call MPI_Abort()
   * otherwise.  This function avoids having to guard abort calls in
   * application code.
   */
  static void Abort ();

  /**
   * Call MPI_Init.  Use of this function avoids guarding MPI init calls in
   * application code. Initialize the Mpi utility class as well.
   */
  static void Initialize (int* argc, char*** argv);

  /**
   * Call MPI_Finalize. Use of this function avoids guarding MPI finalize calls
   * in application code.
    */
  static void Finalize ();

  /**
   * Get the current MPI communicator.  The default communicator is
   * MPI_COMM_WORLD.
   */
  static Mpi::Comm GetComm ();

  /**
   * Set the communicator that is used for the MPI communication routines.  The
   * default communicator is MPI_COMM_WORLD.
   */
  static void SetComm (Mpi::Comm comm);

  /**
   * Return the processor rank (identifier) from 0 through the number of
   * processors minus one.
   */
  static int Rank ();

  /**
   * Return the number of processors (nodes).
   */
  static int Nodes ();
  /** @} */

  /** @{ Statistics handling */
  /**
   * Update the statistics for outgoing messages. Statistics are automatically
   * updated for the reduction calls in MPI.
   */
  static void UpdateOutflow (const int nmsg, const int nbyte);

  /**
   * Update the statistics for incoming messages. Statistics are automatically
   * updated for the reduction calls in MPI.
   */
  static void UpdateInflow (const int nmsg, const int nbyte);

  /**
   * Return the number of outgoing messages.
   */
  static int OutflowMessages ();

  /**
   * Return the number of outgoing message bytes.
   */
  static int OutflowBytes ();

  /**
   * Return the number of incoming messages.
   */
  static int InflowMessages();

  /**
   * Return the number of incoming message bytes.
   */
  static int InflowBytes ();

  /**
   * Get the depth of the reduction trees given the current number
   * of MPI processors.
   */
  static int TreeDepth ();
  /** @} */

private:
  /**
   * Current comunicator which is used into all MPI calling. So you should
   * always call \see Mpi::SetComm and \see Mpi::GetComm before any
   * comunication.
   */
  static Mpi::Comm s_comm;
  /// Number of messages sen out
  static int s_noutmsg;
  /// Number of bytes sent out
  static int s_noutbyte;
  /// Number of messages reieved
  static int s_ninmsg;
  /// Number of bytes reieved
  static int s_ninbyte;
  /// Is class initialized? \see Mpi::Initialize
  static int s_isinit;
  /// Should we do abort or just exit in the serial mode?
  static bool s_doabort;

#ifdef HAVE_MPI
  template <class T>
  static void Reduce (MPI_Op op, T *data, int ndata = 1, int *who = NULL);

  template <class T>
  static void ReduceOne (MPI_Op op, T *data, int ndata = 1,
			 int root = 0, int *who = NULL);

//   /// Performs common functions needed by some of the allToAll methods.
//   static void GatherSetup (int nin, int nout, int *&rcounts, int *&disps);
#endif
};

#include "wrap.cpp"

/** @} */

#endif /* __SAT_WRAP_H__ */
