/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   ref.cxx
 * @brief  Example of Ref<> and Ptr usage
 * @author @jparal
 *
 * @revision{0.3.0}
 * @reventry{2008/06, @jparal}
 * @revmessg{Initial version}
 */

#include "sat.h"

struct CountMe : public RefCount
{
  CountMe () { printf ("CountMe::CountMe ()\n"); }
  ~CountMe () { printf ("CountMe::~CountMe ()\n"); }
  void PrintCnt () { printf ("%d\n", GetRefCount ()); }
};

struct Usage
{
  Usage ()
  {
    _cm.AttachNew (new CountMe);
    Bla (_cm);
  }

  void Bla (CountMe* pcm)
  {
    pcm->PrintCnt ();
    _cm2 = pcm;
  }

  Ref<CountMe> _cm;
  Ref<CountMe> _cm2;
};

int main (int argc, char **argv)
{
  {
    // Usage usg;
    // usg._cm->PrintCnt ();

    CountMe *cm1 = new CountMe;
    CountMe *cm2 = new CountMe;
    RefArray<CountMe> array;
    cm1->PrintCnt ();
    array.PushNew (cm1);
    array.PushNew (cm2);
    cm1->PrintCnt ();
  }

  printf ("Exiting ...\n");
}
