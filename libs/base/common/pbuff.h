/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pbuff.h
 * @brief  Parallel buffer
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-28, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_PBUFF_H__
#define __SAT_PBUFF_H__

#include <iostream>
using namespace std;

class ParallelBuffer;
extern ParallelBuffer plog_buff;

#define DEFAULT_BUFFER_SIZE (128)

/** @addtogroup base_common
 *  @{
 */

/**
 * @brief Parallel buffer
 *
 * Parallel buffer wrap around any ostream class and add function for further
 * manipulation necessary for parallel execution. This class defines a stream
 * buffer class for an ostream class.
 *
 * @revision{1.0}
 * @reventry{2008-02-28, @jparal}
 * @revmessg{Initial version}
 */
class ParallelBuffer : public std::streambuf
{
public:
  /**
   * Create a parallel buffer class.  The object will require further
   * initialization to set up the I/O streams and prefix string.
   */
  ParallelBuffer ();
  /**
   * The destructor simply deallocates any internal data buffers.  It does not
   * modify the output streams.
   */
  virtual ~ParallelBuffer ();

  ///@name Public API
  //@{

  /**
   * Set whether the output stream will be active.  If the parallel buffer
   * stream is disabled, then no data is forwarded to the output streams.  The
   * internal data buffer is deallocated and pointers are reset whenever the
   * parallel buffer is deactivated.
   */
  void Enable (bool active = true);

  /**
   * Set the prefix that begins every new line to the output stream.  A sample
   * prefix is "P=XXXXX: ", where XXXXX represents the node number.
   */
   void SetPrefix (const std::string &text);

  /**
   * Set the primary output stream.  If not NULL, then output data is sent to
   * this stream.  The primary output stream is typically stderr or stdout or
   * perhaps a log file.
   */
  void SetStream (std::ostream *stream);

  /**
   * Write a text string to the output stream.  Note that the string is
   * not actually written until an end-of-line is detected.
   */
  void Output (const std::string &text)
  { Output (text, text.length ()); }

  /**
   * Write a text string of the specified length to the output file.  Note
   * that the string is not actually written until an end-of-line is detected.
   */
  void Output (const std::string &text, const int length);

  //@}
  ///@name streambuff API
  //@{

  /// Synchronize the parallel buffer (called from streambuf).
  virtual int sync ();

#if !defined(__INTEL_COMPILER) && (defined(__GNUG__) || defined(__KCC))
  /**
   * Write the specified number of characters into the output stream (called
   * from streambuf).
   */
  virtual std::streamsize xsputn (const std::string &text, std::streamsize n);
#endif

#ifdef _MSC_VER
   /**
    * Read an overflow character from the parallel buffer (called from
    * streambuf).  This is not implemented.  It is needed by the
    * MSVC++ stream implementation.
    */
   virtual int underflow();
#endif

  /**
   * Write an overflow character into the parallel buffer (called from
   * streambuf).
   */
  virtual int overflow(int ch);
  //@}

private:
  void CopyToBuff (const string &text, const int length);
  void FlushBuff ();         // output internal buffer data to streams

  bool _active;    //< whether this output stream is active
  string _prefix;  //< string prefix to prepend output strings
  ostream* _os;    //< primary output stream for buffer
  char *_buff;     //< internal buffer to store accumulated string
  int _bsize;      //< size of the internal output buffer
  int _bptr;       //< number of charcters in the output buffer
};

/** @} */

#endif /* __SAT_PBUFF_H__ */
