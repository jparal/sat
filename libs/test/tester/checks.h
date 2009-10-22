/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   checks.h
 * @brief  Various checks
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_CHECKS_H__
#define __SAT_CHECKS_H__

#include "base/common/string.h"
#include "results.h"

/// @addtogroup test_tester
/// @{

namespace SAT {
namespace Test {

template< typename Value >
bool Check(Value const value)
{
  return !!value; // doing double negative to avoid silly VS warnings
}


template< typename Expected, typename Actual >
void CheckEqual(TestResults& results, Expected const expected, Actual const actual, TestDetails const& details)
{
    if (!(expected == actual))
    {
        // UnitTest::MemoryOutStream stream;
//         stream
      String s;
      s << "Expected " << expected << " but was " << actual;
        results.OnTestFailure(details, s);
    }
}

void CheckEqual(TestResults& results, char const* expected, char const* actual, TestDetails const& details);

void CheckEqual(TestResults& results, char* expected, char* actual, TestDetails const& details);

void CheckEqual(TestResults& results, char* expected, char const* actual, TestDetails const& details);

void CheckEqual(TestResults& results, char const* expected, char* actual, TestDetails const& details);

template< typename Expected, typename Actual, typename Tolerance >
bool AreClose(Expected const expected, Actual const actual, Tolerance const tolerance)
{
    return (actual >= (expected - tolerance)) && (actual <= (expected + tolerance));
}

template< typename Expected, typename Actual, typename Tolerance >
void CheckClose(TestResults& results, Expected const expected, Actual const actual, Tolerance const tolerance,
                TestDetails const& details)
{
    if (!AreClose(expected, actual, tolerance))
    {
      String s;
      s << "Expected " << expected << " +/- " << tolerance << " but was " << actual;

        results.OnTestFailure(details, s);
    }
}

template< typename Expected, typename Actual >
void CheckArrayEqual(TestResults& results, Expected const expected, Actual const actual,
                int const count, TestDetails const& details)
{
    bool equal = true;
    for (int i = 0; i < count; ++i)
        equal &= (expected[i] == actual[i]);

    if (!equal)
    {
      String s;
      s << "Expected [ ";
        for (int i = 0; i < count; ++i)
	  s << expected[i] << " ";
        s << "] but was [ ";
        for (int i = 0; i < count; ++i)
            s << actual[i] << " ";
        s << "]";

        results.OnTestFailure(details, s);
    }
}

template< typename Expected, typename Actual, typename Tolerance >
bool ArrayAreClose(Expected const expected, Actual const actual, int const count, Tolerance const tolerance)
{
    bool equal = true;
    for (int i = 0; i < count; ++i)
        equal &= AreClose(expected[i], actual[i], tolerance);
    return equal;
}

template< typename Expected, typename Actual, typename Tolerance >
void CheckArrayClose(TestResults& results, Expected const expected, Actual const actual,
                   int const count, Tolerance const tolerance, TestDetails const& details)
{
    bool equal = ArrayAreClose(expected, actual, count, tolerance);

    if (!equal)
    {
      String s;
        s << "Expected [ ";
        for (int i = 0; i < count; ++i)
            s << expected[i] << " ";
        s << "] +/- " << tolerance << " but was [ ";
        for (int i = 0; i < count; ++i)
            s << actual[i] << " ";
        s << "]";

        results.OnTestFailure(details, s);
    }
}

template< typename Expected, typename Actual, typename Tolerance >
void CheckArray2DClose(TestResults& results, Expected const expected, Actual const actual,
                   int const rows, int const columns, Tolerance const tolerance, TestDetails const& details)
{
    bool equal = true;
    for (int i = 0; i < rows; ++i)
        equal &= ArrayAreClose(expected[i], actual[i], columns, tolerance);

    if (!equal)
    {
        String s;
        s << "Expected [ ";
        for (int i = 0; i < rows; ++i)
        {
            s << "[ ";
            for (int j = 0; j < columns; ++j)
                s << expected[i][j] << " ";
            s << "] ";
        }
        s << "] +/- " << tolerance << " but was [ ";
        for (int i = 0; i < rows; ++i)
        {
            s << "[ ";
            for (int j = 0; j < columns; ++j)
                s << actual[i][j] << " ";
            s << "] ";
        }
        s << "]";

        results.OnTestFailure(details, s);
    }
}

} /* namespace Test */
} /* namespace SAT */

/// @}

#endif /* __SAT_CHECKS_H__ */
