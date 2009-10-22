/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   cmdpcle.h
 * @brief  Command for particles
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CMDPCLE_H__
#define __SAT_CMDPCLE_H__

#include "base/sys/porttypes.h"
#include "base/common/comparator.h"

/// @addtogroup simul_pcle
/// @{

/// particle command type
typedef uint32_t pclecmd_t;

/// no command
#define PCLE_CMD_NONE    0x0
/// send left in dimension 0
#define PCLE_CMD_LSEND_0 1 << 0
/// send left in dimension 1
#define PCLE_CMD_LSEND_1 1 << 1
/// send left in dimension 2
#define PCLE_CMD_LSEND_2 1 << 2
/// send right in dimension 0
#define PCLE_CMD_RSEND_0 1 << 3
/// send right in dimension 1
#define PCLE_CMD_RSEND_1 1 << 4
/// send right in dimension 2
#define PCLE_CMD_RSEND_2 1 << 5
/// remove particle
#define PCLE_CMD_REMOVE  1 << 6
/// trace particle in time
#define PCLE_CMD_TRACE   1 << 7
/// Newly arrived particle (during synchronization)
#define PCLE_CMD_ARRIVED 1 << 8

#define PCLE_CMD_LSEND (PCLE_CMD_LSEND_0 | PCLE_CMD_LSEND_1 | PCLE_CMD_LSEND_2)
#define PCLE_CMD_RSEND (PCLE_CMD_RSEND_0 | PCLE_CMD_RSEND_1 | PCLE_CMD_RSEND_2)
#define PCLE_CMD_SEND (PCLE_CMD_LSEND | PCLE_CMD_RSEND)

#define PCLE_CMD_SEND_RIGHT (pclecmd_t)3
#define PCLE_CMD_SEND_LEFT (pclecmd_t)0

/// Macro which construct sending flag based on the dimension @p dim (value
/// 0-3) and direction parameter @p dir (either @p PCLE_CMD_SEND_LEFT or
/// @p PCLE_CMD_SEND_RIGHT)
#define PCLE_CMD_SEND_DIM(dir,dim) (1 << ((pclecmd_t)dim+dir))
/// test whether the send is to the left
#define PCLE_CMD_IS_LSEND(cmd) (cmd & PCLE_CMD_LSEND)
/// test whether the send is to the right
#define PCLE_CMD_IS_RSEND(cmd) (cmd & PCLE_CMD_RSEND)

struct PcleCommandInfo
{
  PcleCommandInfo ()
    : pid(0), cmd(0) {};
  PcleCommandInfo (size_t ppid, pclecmd_t pcmd)
    : pid(ppid), cmd(pcmd) {}

  size_t pid;
  pclecmd_t cmd;
};

template <>
class Comparator<PcleCommandInfo, PcleCommandInfo>
{
public:
  static int Compare (PcleCommandInfo const& r1, PcleCommandInfo const& r2)
  {
    if (r1.pid < r2.pid)
      return -1;
    else if (r2.pid < r1.pid)
      return 1;
    else
      return 0;
  }
};

template <>
class Comparator<PcleCommandInfo, size_t>
{
public:
  static int Compare (PcleCommandInfo const& r1, size_t const& r2)
  {
    if (r1.pid < r2) return -1;
    else if (r2 < r1.pid) return 1;
    else return 0;
  }
};

/// @}

#endif /* __SAT_CMDPCLE_H__ */
