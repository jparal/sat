/******************************************************************************
 *   Copyright (C) by Jan Paral and SAT team                                  *
 *   See docs/license/sat file for copying and redistribution conditions.     *
 ******************************************************************************/
/**
 * @file   init.cpp
 * @author @jparal
 *
 * @revision{1.1}
 * @reventry{2010/02, @jparal}
 * @revmessg{Initial version}
 */

template<class T, int D>
void ShockCAMCode<T,D>::PreInitialize (const ConfigFile &cfg)
{
  if (cfg.Exists ("shock"))
  {
    _shock = true;
    // cfg.GetValue ("shock.amp", _amp);
  }
  else
  {
    DBG_WARN ("Skipping shock initialization!");
    _shock = false;
  }
}

template<class T, int D>
void ShockCAMCode<T,D>::PostInitialize (const ConfigFile &cfg)
{
  if (!_shock) return;

  // if (Math::Abs(TBase::_phi) > M_EPS || Math::Abs(TBase::_psi) > M_EPS)
  //   DBG_WARN ("we expect B0 to be parallel to X-axis");

  // Vector<T,D> l, k;
  // VecField &U = this->_U;

  // for (int i=0; i<D; ++i)
  // {
  //   int nc = U.Size (i)-1;
  //   int gh = U.GetLayout ().GetGhost (i);
  //   int np = U.GetLayout ().GetDecomp ().GetSize (i);
  //   T dx = U.GetMesh ().GetResol (i);
  //   _k[i] = (M_2PI * (T)_npex[i]) / ((T)((nc - 2*gh) * np));

  //   k[i] = _k[i] / dx;
  //   l[i] = M_2PI/k[i];
  // }

  DBG_INFO ("Shock initialization:");
}


// template<class T, int D>
// void ShockCAMCode<T,D>::BInitAdd (VecField &b)
// {
//   PosVector mv, nc, ip, dx, lx, cx;
//   for (int i=0; i<D; ++i)
//   {
//     nc[i] = b.Size(i)-1;
//     ip[i] = b.GetLayout().GetDecomp().GetPosition(i);
//     dx[i] = U.GetMesh().GetResol(i);
//     lx[i] = nc[i] * ip[i] * dx[i];
//     cx[i] = lx[i] * _rpos[i];
//     mv[i] = 0.;
//   }
//   mv[D-1] = _amp;

//   DomainIterator<D> it( b.GetDomainAll() );
//   do
//   {
//     for (int i=0; i<D; ++i)
//       pos[i] = ( (T)(it.GetLoc()[i])+ ip[i]*nc[i] ) * dx[i];

//     PosVector xp = pos - cx;
//     T r3 = xp.Norm() * xp.Norm2();

//     xp.Normalize();
//     b(it) += (3. * (mv*xp) * xp - mv)/r3
//   }
//   while (it.Next())
// }
