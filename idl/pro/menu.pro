  pro menu
  common d3fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common rot, rbx, rby, rbz, rux,ruy, ruz
  common poynt, csx,csy,csz
  common nnn, ncx,ncy,ncz, num
  common f, ff,fff, a,b,c
  common coor, t,x,y,z
  common list, list0,list1,list2,list3
  common head, tit, xlab,ylab,zlab
  common util, fft, shift, sign
  common fil, filnam
  common exe, filexe
  common  textid, textfil, textexe 
  filnam='cam.ps'
  filexe=' '
  tit=' '
  xlab=' '
  ylab=' '
  zlab=' '
  t=0
  x=0
  y=0
  z=0
  a=1
  b=0
  c=0
  fft=0
  shift=.0
  sign=1.
  fname='            '
  read,' Enter filename name : ', fname
  restore, fname
  inter, cex
  inter, cey
  inter, cez
  rot3, cbx, cby, cbz, rbx, rby, rbz
  rot3, cux, cuy, cuz, rux, ruy, ruz 
  csx= cey*cbz-cez*cby
  csy= cez*cbx-cbz*cex
  csz= cex*cby-cbx*cey 
  ff=cbx
  fff=cby
  base = widget_base(title=' Graf CAM ',/row)
  lcol=widget_base(base,/frame, /column)
  rcol=widget_base(base,/frame, /column,title=' MENU ')
  draw=widget_draw(lcol, xsize=2*256, ysize=2*256) 
  atext=widget_label(lcol,value='file = '+fname)
  base3 = widget_base(lcol,/row)
   bb=widget_label(base3,value='PS file output: ')
   textfil=widget_text(base3,/editable)
   bbb=widget_label(base3,value='Execute : ')
   textexe=widget_text(base3,/editable) 
  xpdmenu, [ '"Fields" {','"Bx"','"By"','"Bz"', $
     '"BxBy"','"BxBz"','"ByBz"', $
   '"RotBx"','"RotBy"','"RotBz"', $
   '"RotBxRotBy"','"RotBxRotBz"','"RotByRotBz"', $
    '"Ex"','"Ey"','"Ez"', $
    '"ExEy"','"ExEz"','"EyEz"', $
    '"Sx"','"Sy"','"Sz"', $
    '"SxSy"','"SxSz"','"SySz"', $
     '}','"Particles" {', $ 
     '"ux"','"uy"','"uz"',$
     '"uxuy"','"uxuz"','"uyuz"', $ 
     '"Rotux"','"Rotuy"','"Rotuz"',$
   '"RotuxRotuy"','"RotuxRotuz"','"RotuyRotuz"', $
     '"dn"','"pe"','}', '"Quit"'], rcol
  xmenu, ['Slicer','Contour','Image_cont', $
    'Surface', $
    'Vector','Plot','Oplot'],/exclusive,/Frame,rcol
  mmm=widget_base(rcol,/column)
  mmm1=widget_base(mmm,/row)
  xmenu, ['tx','ty','tz','xy','xz','yz'],/exclusive,/Frame,mmm1
  xmenu, ['t','x','y','z'],/exclusive,/Frame,mmm1
  xmenu, ['FFT','No FFT'],/exclusive,/Frame,mmm1
  xmenu, ['1','2x1','1x2','3x1','1x3','2x2'],/exclusive,/Frame,mmm1
;  xmenu, ['SHIFT','No SHIFT'],/exclusive,/Frame,mmm2 
  xmenu, ['+','-'],/exclusive,/Frame,mmm1
   base1=widget_base(rcol,/row)
   labelx=widget_label(base1,value='    x',/frame)
   list0=widget_list(base1, value=sindgen(ncx), ysize=5)
   labely=widget_label(base1,value='    y',/frame)
   list1=widget_list(base1, value=sindgen(ncy), ysize=5)
   labelz=widget_label(base1,value='    z',/frame)
   list2=widget_list(base1, value=sindgen(ncz), ysize=5)
   labelt=widget_label(base1,value='    t',/frame)
   list3=widget_list(base1, value=sindgen(num+1), ysize=5)
  rrcol= widget_base(rcol,/row)
  w1= widget_button(rrcol, value=' DRAW ')
;  w2= widget_button(rrcol, value=' PRINT ')
  w3= widget_button(rrcol, value=' EXECUTE ')
;  w3= widget_button(rrcol, value=' WCALC ')
  widget_control, base, /realize
  widget_control,get_value=window, draw
  wset, window
  xmanager, 'menu', base
  end
