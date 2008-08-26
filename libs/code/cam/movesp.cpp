/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   movesp.cpp
 * @author @jparal
 *
 * @revision{1.0}
 * @reventry{2008/07, @jparal}
 * @revmessg{Initial version}
 */

template<class B, class T, int D>
void CAMCode<B,T,D>::MoveSp (TSpecie *sp, ScaField &dnsa, VecField &Usa,
			     ScaField &dnsb, VecField &Usb)
{
  dnsa = (T)0.; Usa = (T)0.;
  dnsb = (T)0.; Usb = (T)0.;

  T dt = _time.Dt ();
  T dta = (sp->ChargePerPcle () / sp->MassPerPcle ()) * dt;
  T dth = 0.5 * dta;

  const PosVector p05 (0.5);
  PosVector p; // Particle position
  VelVector v, vh; // Particle velocity and half step velocity
  FldVector ep, bp; // E and B fields at particle position

  BilinearWeightCache<T,D> cache;
  size_t npcle = sp->GetSize ();
  for (int pid=0; pid<npcle; ++pid)
  {
    TParticle &pcle = sp->Get (pid);

    v = pcle.vel;
    p = pcle.pos;
    CartStencil::BilinearWeight (_B, p, cache, bp);

    // Electric field is shifted
    p  += p05;
    CartStencil::BilinearWeight (_E, p, ep);

    // Position advance
    p = pcle.pos;
    for (int i=0; i<D; ++i)
      p[i] += dt * v[i];

    // Velocity advance
    vh = v;
    vh += dth * (ep + v % bp);
    v += dta * (ep + vh % bp);

    cache.ipos += 1; // since dn has ghost = 1
    CartStencil::BilinearWeightAdd (dnsa, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usa, cache, v);

    // Update position and velocity
    pcle.pos = p;
    pcle.vel = v;

    if_pf (static_cast<B*>(this)->PcleBCAdd (sp, pid, pcle.pos, pcle.vel) ||
	   PcleBC (sp, pid, pcle.pos, pcle.vel))
    {
      continue;
    }

    FillCache (p, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dnsb, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usb, cache, v);
  }

  /**********************************************************************/
  /* Synchronize particles:                                             */
  /* 1) repeat till we have any particles marked for transfer           */
  /*   1a) synchronize                                                  */
  /*   1b) apply boundary condition to the incoming particles           */
  /*   1c) update a position of newcomers (already done in the previous */
  /*       calling of boundary conditions                               */
  /*   1d) update moments dnsb and Usb                                  */
  /* 2) remove old particles                                            */
  /**********************************************************************/
  int send = 0, recv = 0, clean = 0;
  sp->Sync (&send, &recv);

  TSpecieCommandIterator iter = sp->GetCommandIterator (PCLE_CMD_ARRIVED);
  while (iter.HasNext ())
  {
    const PcleCommandInfo& info = iter.Next (true);
    TParticle &pcle = sp->Get (info.pid);

    FillCache (pcle.pos, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dnsb, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usb, cache, pcle.vel);
  }

  sp->Clean (&clean);
}
