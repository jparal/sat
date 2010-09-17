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
void DipoleCAMCode<T,D>::PreInitialize (const ConfigFile &cfg)
{
  if (cfg.Exists ("dipole"))
  {
    _dipole = true;
    cfg.GetValue ("dipole.amp", _amp);
    cfg.GetValue ("dipole.rpos", _rpos);
    cfg.GetValue ("dipole.radius", _radius);
    _radius2 = _radius * _radius;
  }
  else
  {
    DBG_WARN ("Skipping dipole initialization!");
    _dipole = false;
  }
}

template<class T, int D>
void DipoleCAMCode<T,D>::PostInitialize (const ConfigFile &cfg)
{
  if (!_dipole) return;

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

  FldVector xp = 0., mv = 0., b0 = ((TBase*)this)->_B0;
  T r3 = _radius2 * _radius;
  xp[0] = _radius;
  mv[D-1] = _amp;
  b0 += ((T)3.*(mv*xp) * xp - mv)/r3;

  DBG_INFO ("Dipole initialization:");
  DBG_INFO ("  amplitude      : "<<_amp);
  DBG_INFO ("  relative pos.  : "<<_rpos);
  DBG_INFO ("  planet radius  : "<< Math::Sqrt(_radius2));
  DBG_INFO ("  B/B0 @ surface : "<< b0.Norm ());
}


// template<class T, int D>
// void DipoleCAMCode<T,D>::BInitAdd (VecField &b)
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