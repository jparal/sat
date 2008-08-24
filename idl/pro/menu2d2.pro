;
  pro menu2d2
  common d2fields, bx,by,bz,$
                    ex,ey,ez,$
                    ux,uy,uz,$
                    dn,pe
  common momsep, dn1,ux1,uy1,uz1, $
                 dn2,ux2,uy2,uz2
  common dim, dx,dy
  common ran, u, tp
  common rot, rbx, rby, rbz, rux,ruy, ruz
  common poynt, sx,sy,sz
  common nnn, ncx,ncy, num
  common f, ff,fff, a,b,c
  common coor, x,y
  common list, list0,list1,list2,list3
  common head, tit, xlab,ylab
  common util, fft, shift, sign
  common fil, filnam
  common exe, filexe
  common  textid, textfil, textexe 
  filnam='cam.ps'
  u=0.
  tp=1.
  filexe=' '
  tit=' '
  xlab=' '
  ylab=' '
  zlab=' '
  x=0
  y=0
  a=1
  b=0
  c=0
  fft=0
  shift=.0
  sign=1.
  fname=  PICKFILE(/READ,filter='*.dat')
  restore, fname
  int, ex
  int, ey
  int, ez
  rot2d, dx,dy, bx, by, bz, rbx, rby, rbz
  rot2d, dx,dy, ux, uy, uz, rux, ruy, ruz 
  sx= ey*bz-ez*by
  sy= ez*bx-bz*ex
  sz= ex*by-bx*ey 
  ff=bx
  fff=by
  base = widget_base(title=' Graph CAM 2D ',/row)
  lcol=widget_base(base,/frame, /column)
  rcol=widget_base(base,/frame, /column,title=' MENU ')
  draw=widget_draw(lcol, xsize=2*256, ysize=2*256) 
  atext=widget_label(lcol,value='file = '+fname)
  base3 = widget_base(lcol,/row)
   bb=widget_label(base3,value='PS file output: ')
   textfil=widget_text(base3,/editable)
   bbb=widget_label(base3,value='Execute : ')
   textexe=widget_text(base3,/editable) 
  xpdmenu, [ '"Fields" {','"B"','"Bx"','"By"','"Bz"', $
     '"BxBy"','"BxBz"','"ByBz"', $
   '"RotBx"','"RotBy"','"RotBz"', $
   '"RotBxRotBy"','"RotBxRotBz"','"RotByRotBz"', $
    '"E"','"Ex"','"Ey"','"Ez"', $
    '"ExEy"','"ExEz"','"EyEz"', $
    '"S"','"Sx"','"Sy"','"Sz"', $
    '"SxSy"','"SxSz"','"SySz"', $
     '}','"Particles" {', $ 
     '"u"','"ux"','"uy"','"uz"',$
     '"uxuy"','"uxuz"','"uyuz"', $ 
     '"Rotux"','"Rotuy"','"Rotuz"',$
   '"RotuxRotuy"','"RotuxRotuz"','"RotuyRotuz"', $
     '"dn"','"pe"','}',$
    '"Momsep" {','"dn1"', $ 
     '"u1"','"ux1"','"uy1"','"uz1"',$
     '"uxuy1"','"uxuz1"','"uyuz1"', $ 
     '"dn2"', $ 
     '"u2"','"ux2"','"uy2"','"uz2"',$
     '"uxuy2"','"uxuz2"','"uyuz2"', $ 
     '}', $
      '"Quit"'], rcol
  xmenu, ['Slicer','Contour','Image_cont', $
    'Surface', 'Show3','Shade_surf','Image',$
   'Image_cont1', $
    'Vector','Plot','Oplot'],/exclusive,/Frame,rcol
  mmm=widget_base(rcol,/column)
  mmm1=widget_base(mmm,/row)
  xmenu, ['xy'],/exclusive,/Frame,mmm1
  xmenu, ['x','y'],/exclusive,/Frame,mmm1
  xmenu, ['FFT','No FFT'],/exclusive,/Frame,mmm1
  xmenu, ['1','2x1','1x2','3x1','1x3','2x2'],/exclusive,/Frame,mmm1
  xmenu, ['+','-'],/exclusive,/Frame,mmm1
   base1=widget_base(rcol,/row)
   labelx=widget_label(base1,value='    x',/frame)
   list0=widget_list(base1, value=sindgen(ncx), ysize=5)
   labely=widget_label(base1,value='    y',/frame)
  list1=widget_list(base1, value=sindgen(ncy), ysize=5)
  rrcol= widget_base(rcol,/column)
   rrrcol= widget_base(rrcol,/row)
  rrlcol= widget_base(rrcol,/row)
  w1= widget_button(rrrcol, value=' DRAW ')
  w2= widget_button(rrrcol, value=' PRINT ')
  w3= widget_button(rrrcol, value=' EXECUTE ')
  w4= widget_button(rrlcol, value=' WCALC ')
  w5= widget_button(rrlcol, value=' XPALETTE ')
  w6= widget_button(rrlcol, value=' NEW FILE ')
  widget_control, base, /realize
  widget_control,get_value=window, draw
  wset, window
  xmanager, 'menu2d2', base
  return
  end
