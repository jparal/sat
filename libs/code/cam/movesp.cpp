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
  T vmax2 = _vmax*_vmax;

  const PosVector p05 (0.5);
  const PosVector dxi = _meshp.GetResolInv ();
  PosVector x; // Particle position
  VelVector v, vh; // Particle velocity and half step velocity
  FldVector ep, bp; // E and B fields at particle position

  BilinearWeightCache<T,D> cache;
  size_t npcle = sp->GetSize ();
  for (int pid=0; pid<npcle; ++pid)
  {
    TParticle &pcle = sp->Get (pid);

    /// v^0, x^1/2
    v = pcle.vel;
    x = pcle.pos;

    /// Obtain E,B at x^1/2
    CartStencil::BilinearWeight (_B, x, cache, bp);
    x += p05; // Electric field is shifted
    CartStencil::BilinearWeight (_E, x, ep);

    /// Advance velocity v^0 -> v^1
    vh = v;
    vh += dth * (ep + v % bp);
    v += dta * (ep + vh % bp);

    /// Cap the maximal speed of pcle
    // if (_vmax > 0. && v.Norm2() > vmax2)
    //   v.Normalize (_vmax);

    /// Advance position x^1/2 -> x^3/2
    x = pcle.pos;
    for (int i=0; i<D; ++i)
      x[i] += (dt * v[i]) * dxi[i];

    // Update position and velocity
    pcle.pos = x;
    pcle.vel = v;

    /// Collect moments at x^1/2 ; v^1
    cache.ipos += 1; // since dn has ghost = 1
    CartStencil::BilinearWeightAdd (dnsa, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usa, cache, pcle.vel);

    if_pf (static_cast<B*>(this)->PcleBCAdd (sp, pid, pcle) ||
           PcleBC (sp, pid, pcle))
    {
      continue;
    }

    /// Collect moments at x^3/2 ; v^1
    FillCache (pcle.pos, cache);
    cache.ipos += 1;
    CartStencil::BilinearWeightAdd (dnsb, cache, (T)1.);
    CartStencil::BilinearWeightAdd (Usb, cache, pcle.vel);
  }
}
