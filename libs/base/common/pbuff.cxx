/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   pbuff.cxx
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-28, @jparal}
 * @revmessg{Initial version}
 */

#include "pbuff.h"
#include "base/sys/assert.h"

#include <string.h>
#include <stdio.h>

ParallelBuffer plog_buff;

ParallelBuffer::ParallelBuffer ()
{
  _active = true;
  _prefix = "";
  _os     = &cout;
  _buff   = NULL;
  _bsize  = 0;
  _bptr   = 0;
}

ParallelBuffer::~ParallelBuffer ()
{
  if (_buff) delete [] _buff;
}

void ParallelBuffer::Enable (bool active)
{
  if (!_active && _buff)
  {
    delete [] _buff;
    _buff = NULL;
    _bsize = 0;
    _bptr = 0;
  }
  _active = active;
}

void ParallelBuffer::SetPrefix (const std::string &text)
{
  _prefix = text;
}

void ParallelBuffer::SetStream (std::ostream *stream)
{
  _os = stream;
}

void ParallelBuffer::Output (const std::string &text, const int length)
{
  if ((length <= 0) || !_active)
    return;

  // If we need to allocate the internal buffer
  if (!_buff)
  {
    _buff = new char[DEFAULT_BUFFER_SIZE];
    _bsize = DEFAULT_BUFFER_SIZE;
    _bptr  = 0;
  }

  // If the buffer pointer is zero, then prepend the prefix if not empty
  if ((_bptr == 0) && !_prefix.empty ())
    CopyToBuff (_prefix, _prefix.length());

  // Search for an end-of-line in the string
  int eol_ptr = 0;
  while ((eol_ptr < length) && (text[eol_ptr] != '\n'))
    ++eol_ptr;

  // If no end-of-line found, copy the entire text string but no output
  if (eol_ptr == length)
  {
    CopyToBuff (text, length);
  }
  else
  {
    const int ncopy = eol_ptr+1;
    CopyToBuff (text, ncopy);
    FlushBuff ();
    if (ncopy < length)
      Output (text.substr(ncopy), length-ncopy);
  }
}

void ParallelBuffer::CopyToBuff (const std::string &text, const int length)
{
  // First check whether we need to increase the size of the buffer
  if (_bptr+length > _bsize)
  {
    const int new_size = _bptr+length > 2*_bsize ? _bptr+length : 2*_bsize;
    char *new_buffer = new char[new_size];

    if (_bptr > 0)
      (void) strncpy(new_buffer, _buff, _bptr);

    delete [] _buff;

    _buff  = new_buffer;
    _bsize = new_size;
  }

  // Copy data from the input into the internal buffer and increment pointer
   SAT_ASSERT (_bptr+length <= _bsize);

   strncpy (_buff + _bptr, text.c_str(), length);
   _bptr += length;
}

void ParallelBuffer::FlushBuff ()
{
  if (_bptr <= 0)
    return;

  if (_os)
  {
    _os->write (_buff, _bptr);
    _os->flush ();
  }
  _bptr = 0;
}

int ParallelBuffer::sync()
{
   const int n = pptr() - pbase();
   if (n > 0)
     Output (pbase(), n);

   return 0;
}

#if !defined(__INTEL_COMPILER) && (defined(__GNUG__) || defined(__KCC))
std::streamsize ParallelBuffer::xsputn (const string &text, streamsize n)
{
  sync();
  if (n > 0)
    Output (text, n);

  return n;
}
#endif

int ParallelBuffer::overflow (int ch)
{
  const int n = pptr() - pbase();
  if (n && sync ())
    return EOF;

  if (ch != EOF)
  {
    char character[2];
    character[0] = (char)ch;
    character[1] = 0;
    Output (character, 1);
  }
  pbump (-n);

  return 0;
}

#ifdef _MSC_VER
// Should never read from here
int ParallelBuffer::underflow ()
{
  return EOF;
}
#endif
