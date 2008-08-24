;
  pro menu2drd
  common d2fields, bx,by,bz,$
                    ex,ey,ez,$
                    ux,uy,uz,$
                    dn,pe
  common momsep, dn1,ux1,uy1,uz1, $
                 dn2,ux2,uy2,uz2
  common dim, dx,dy
   common rot, rbx, rby, rbz, rux,ruy, ruz
  common poynt, sx,sy,sz
  common f, ff,fff 
  fname= PICKFILE(/READ,filter='*.dat')
  restore,fname
  int, ex
  int, ey
  int, ez
  rot2d, dx,dy, bx, by, bz, rbx, rby, rbz
  rot2d, dx,dy, ux, uy, uz, rux, ruy, ruz 
  sx= ey*bz-ez*by
  sy= ez*bx-bz*ex
  sz= ex*by-bx*ey 
  print,'finished ', fname
  return
  end 
