/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   tester/macros.h
 * @brief  Main macros for esambling test cases and suites
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2007/03, @jparal}
 * @revmessg{Initial version}
 */

#ifndef __SAT_MACROS_H__
#define __SAT_MACROS_H__

/// @addtogroup test_tester
/// @{

#include "checks.h"
#include "exception.h"
#include "details.h"

#define SUITE(Name)                                                     \
  namespace Name {                                                      \
    namespace UnitTestSuite {                                           \
      inline char const* GetSuiteName () {                              \
        return #Name ;                                                  \
      }                                                                 \
    }                                                                   \
  }                                                                     \
  namespace Name

#define TEST_EX(Name, List)                                             \
  class Test##Name : public SAT::Test::Test                             \
  {                                                                     \
  public:                                                               \
    Test##Name() : Test(#Name,                                          \
                        UnitTestSuite::GetSuiteName(),                  \
                        __FILE__,                                       \
                        __LINE__) {}                                    \
  private:                                                              \
    virtual void RunImpl(SAT::Test::TestResults& testResults_) const;   \
  } test##Name##Instance;                                               \
                                                                        \
  SAT::Test::ListAdder adder##Name (List, &test##Name##Instance);       \
                                                                        \
  void Test##Name::RunImpl(SAT::Test::TestResults& testResults_) const


#define TEST(Name) TEST_EX(Name, SAT::Test::Test::GetTestList())


#define TEST_FIXTURE_EX(Fixture, Name, List)                            \
  class Fixture##Name##Helper : public Fixture                          \
  {                                                                     \
  public:                                                               \
    Fixture##Name##Helper(SAT::Test::TestDetails const& details)        \
      : m_details(details) {}                                           \
    void RunTest(SAT::Test::TestResults& testResults_);                 \
    SAT::Test::TestDetails const& m_details;                            \
  private:                                                              \
    Fixture##Name##Helper(Fixture##Name##Helper const&);                \
    Fixture##Name##Helper& operator =(Fixture##Name##Helper const&);    \
  };                                                                    \
                                                                        \
  class Test##Fixture##Name : public SAT::Test::Test                    \
  {                                                                     \
  public:                                                               \
    Test##Fixture##Name() : Test(#Name,                                 \
                                 UnitTestSuite::GetSuiteName(),         \
                                 __FILE__,                              \
                                 __LINE__) {}                           \
  private:                                                              \
    virtual void RunImpl(SAT::Test::TestResults& testResults_) const;   \
  } test##Fixture##Name##Instance;                                      \
                                                                        \
  SAT::Test::ListAdder                                                  \
  adder##Fixture##Name (List, &test##Fixture##Name##Instance);          \
                                                                        \
  void Test##Fixture##Name::RunImpl                                     \
  (SAT::Test::TestResults& testResults_) const                          \
  {                                                                     \
    char* fixtureMem = new char[sizeof(Fixture##Name##Helper)];         \
    Fixture##Name##Helper* fixtureHelper;                               \
    try {                                                               \
      fixtureHelper = new(fixtureMem) Fixture##Name##Helper(m_details); \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception while constructing fixture " #Fixture);   \
      delete[] fixtureMem;                                              \
      return;                                                           \
    }                                                                   \
    fixtureHelper->RunTest(testResults_);                               \
    try {                                                               \
      fixtureHelper->~Fixture##Name##Helper();                          \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception while destroying fixture " #Fixture);     \
    }                                                                   \
    delete[] fixtureMem;                                                \
  }                                                                     \
  void Fixture##Name##Helper::RunTest                                   \
  (SAT::Test::TestResults& testResults_)

#define TEST_FIXTURE(Fixture,Name) \
  TEST_FIXTURE_EX(Fixture, Name, SAT::Test::Test::GetTestList())

/*******************************************************************/
/*******************************************************************/

#define CHECK(value)                                                    \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      if (!SAT::Test::Check(value))                                     \
        testResults_.OnTestFailure                                      \
          ( SAT::Test::TestDetails(m_details, __LINE__), #value);       \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK(" #value ")");                   \
    }                                                                   \
  } while (0)

#define CHECK_EQUAL(expected, actual)                                   \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      SAT::Test::CheckEqual                                             \
        (testResults_, expected, actual,                                \
         SAT::Test::TestDetails(m_details, __LINE__));                  \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK_EQUAL(" #expected ", " #actual ")"); \
    }                                                                   \
  } while (0)

#define CHECK_CLOSE(expected, actual, tolerance)                        \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      SAT::Test::CheckClose                                             \
        (testResults_, expected, actual, tolerance,                     \
         SAT::Test::TestDetails(m_details, __LINE__));                  \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK_CLOSE(" #expected ", " #actual ")"); \
    }                                                                   \
  } while (0)

#define CHECK_ARRAY_EQUAL(expected, actual, count)                      \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      SAT::Test::CheckArrayEqual                                        \
        (testResults_, expected, actual, count,                         \
         SAT::Test::TestDetails(m_details, __LINE__));                  \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK_ARRAY_EQUAL(" #expected ", " #actual ")"); \
    }                                                                   \
  } while (0)

#define CHECK_ARRAY_CLOSE(expected, actual, count, tolerance)           \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      SAT::Test::CheckArrayClose                                        \
        (testResults_, expected, actual, count,                         \
         tolerance, SAT::Test::TestDetails(m_details, __LINE__));       \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK_ARRAY_CLOSE(" #expected ", " #actual ")"); \
    }                                                                   \
  } while (0)

#define CHECK_ARRAY2D_CLOSE(expected, actual, rows, columns, tolerance) \
  do                                                                    \
  {                                                                     \
    try {                                                               \
      SAT::Test::CheckArray2DClose                                      \
        (testResults_, expected, actual, rows, columns, tolerance,      \
         SAT::Test::TestDetails(m_details, __LINE__));                  \
    }                                                                   \
    catch (...) {                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Unhandled exception in CHECK_ARRAY_CLOSE(" #expected ", " #actual ")"); \
    }                                                                   \
  } while (0)


#define CHECK_THROW(expression, ExpectedExceptionType)                  \
  do                                                                    \
  {                                                                     \
    bool caught_ = false;                                               \
    try { expression; }                                                 \
    catch (ExpectedExceptionType const&) { caught_ = true; }            \
    if (!caught_)                                                       \
      testResults_.OnTestFailure                                        \
        (SAT::Test::TestDetails(m_details, __LINE__),                   \
         "Expected exception: \"" #ExpectedExceptionType "\" not thrown"); \
  } while(0)

#define CHECK_ASSERT(expression)                        \
  CHECK_THROW(expression, SAT::Test::AssertException);

/// @}

#endif /* __SAT_MACROS_H__ */
