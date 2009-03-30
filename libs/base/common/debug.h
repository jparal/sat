/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   debug.h
 * @brief  Debug macros
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008-02-25, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_DEBUG_H__
#define __SAT_DEBUG_H__

#include "satconfig.h"
#include "plog.h"

/** @addtogroup base_common
 *  @{
 */

namespace Debug {

struct Function
{
  const char *_cls, *_fnc;
  Function (const char *cls, const char *fnc) : _cls(cls), _fnc(fnc)
  { plog << "=> " << _cls << "::"  << _fnc << " ()" << endl; }
  ~Function ()
  { plog << "<= " << _cls << "::"  << _fnc << " ()" << endl; }
};

}; /* namespace Debug */


#if !defined(DEBUG_LEVEL)
#  warning Macro DEBUG_LEVEL is not defined. Setting to default value 2
#  define DEBUG_LEVEL 2
#endif

#if (DEBUG_LEVEL < 0) || (DEBUG_LEVEL > 3)
#  warning Macro DEBUG_LEVEL is not a valid number. Setting to default value 2
#  undef DEBUG_LEVEL
#  define DEBUG_LEVEL 2
#endif

#define DBG_FUNC(cls,fnc)                       \
  Debug::Function __func(#cls, #fnc);
#define DBG_SECT(sec)

#if (DEBUG_LEVEL >= 3)
#  define DBG_PRINT(msg, tag)						\
  plog << tag " " << __FILE__ << "(" << __LINE__ << "): " << msg << endl;
#else
#  define DBG_PRINT(msg, tag)			\
  plog << tag " " << msg << endl;
#endif

#define DBG_SECTION(manip)
#define DBG_TUNE(manip) // plog << manip; Manipulators ... Enable all (all,)
#define DBG_INFO(msg)  DBG_PRINT(msg, "(II)")
#define DBG_WARN(msg)  DBG_PRINT(msg, "(WW)")
#define DBG_ERROR(msg) DBG_PRINT(msg, "(EE)")
#define DBG_LINE(msg)  DBG_PRINT("===================================", "(==)");

#if (DEBUG_LEVEL >= 1)
#  define DBG_INFO1(msg) DBG_PRINT(msg, "(11)")
#else
#  define DBG_INFO1(msg)
#endif

#if (DEBUG_LEVEL >= 2)
#  define DBG_INFO2(msg) DBG_PRINT(msg, "(22)")
#else
#  define DBG_INFO2(msg)
#endif

#if (DEBUG_LEVEL >= 3)
#  define DBG_INFO3(msg) DBG_PRINT(msg, "(33)")
#else
#  define DBG_INFO3(msg)
#endif

#define DBG_PREFIX(msg) plog_buff.SetPrefix (msg);
#define DBG_ENABLE(enb) plog_buff.Enable (enb);
#define SAT_ABBORT(msg) DBG_ERROR(msg << "\nAbborting!!!"); plog.flush (); exit (1);

/**
 * @def DBG_PREFIX
 * Set a prefix in the debug output.
 * @code
 * char cproc[5];
 * snprintf (cproc, 5, "%.2d> ", iproc);
 * DBG_PREFIX (cproc);
 * @endcode
 * will result (for the processor 1) in "01> ....." output from all (DBG_*)
 * debug macros.
 * @def DBG_TUNE
 * Add manipulators into the stream. Except of all manipulators supported by
 * std library we add following:
 * - \b all Print all processes
 * - \b master Only first process will print
 * - \b mine Only this process will print
 * @def DBG_ENTER
 * Use this macro when entering some function. Using this macro is not
 * mandatory and you are leaving the function on the end of program block.
 * @def DBG_SECTION
 * Same as DBG_ENTER but this time all messages following this macro in current
 * program block are part of the specified section
 * (i.e. @b cam.efield.update.).
 * @remarks This feature is not implemented yet.
 * @see @ref DebugSection for more details about available sections
 * @todo We could simply implement a filter which would suppress some of the
 *       messages using wildcharts as verbosity parser in CS.
 * @def DBG_ERROR
 * Print standard error but don't quit or anything.
 * @def DBG_WARN
 * Print warning. Use in situations when you think that user could forgot
 * something or do something wrong.
 * @def DBG_INFO
 * Print information character messages. Those will be printed always thus they
 * can't be suppressed by configure option @bold{--debug-level=0}.
 * @def DBG_INFO1
 * Use this macro for supplemental messages. Use it only for output which is
 * not repeating often.  These messages can be suppressed by specifying
 * @bold{--debug-level=0} argument during configuration process.
 * @def DBG_INFO2
 * Use this macro for supplemental messages. Use it for output which is
 * repeating regularly.  These messages can be suppressed by specifying
 * @bold{--debug-level=[0|1]} argument during configuration process.
 * @def DBG_INFO3
 * Use this macro for supplemental messages. Use it for output which is
 * repeating with high frequency.  These messages can be suppressed by
 * specifying @bold{--debug-level=[0|1|2]} argument during configuration
 * process.
 */

/** @} */

#endif /* __SAT_DEBUG_H__ */
