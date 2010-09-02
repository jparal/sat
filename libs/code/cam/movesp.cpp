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
  const PosVector dxi = _meshp.GetResolInv ();
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

    // Velocity advance
    vh = v;
    vh += dth * (ep + v % bp);
    v += dta * (ep + vh % bp);

    /// @TODO make the constant more sensible
    const T vmax = 10.;
    if (v.Norm2() > vmax*vmax)
    {
      v.Normalize ();
      v *= vmax;
    }

    // Position advance
    p = pcle.pos;
    for (int i=0; i<D; ++i)
      p[i] += (dt * v[i]) * dxi[i];

    cache.ipos += 1; // since dn has ghost = 1
    CartStencil::BilinearWeightAdd (dnsa, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usa, cache, v);

    // Update position and velocity
    pcle.pos = p;
    pcle.vel = v;

    if_pf (static_cast<B*>(this)->PcleBCAdd (sp, pid, pcle) ||
           PcleBC (sp, pid, pcle))
    {
      continue;
    }

    FillCache (p, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dnsb, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usb, cache, v);
  }
}
