;
  pro menup
  common d3fields, cbx,cby,cbz,$
                    cex,cey,cez,$
                    cux,cuy,cuz,$
                    cdn,cpe
  common d3particles, cx,cy,cz,cvx,cvy,cvz
  common nnn, ncx,ncy,ncz, num
  common f, ff, a,b,c
  common coor, t,x,y,z
  common list, list0,list1,list2,list3
  common head, tit, xlab,ylab,zlab
  common util, fft, shift, sign
  common fil, filnam
  common histo, quoi, ih, h
  filnam='cam.ps'
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
  read,' Enter filename name - fields : ', fname
  restore, fname
  read,' Enter filename name - particles : ', fname
  restore, fname
  ff=cby
  base = widget_base(title=' Graf CAM ',/row)
  lcol=widget_base(base,/frame, /column)
  rcol=widget_base(base,/frame, /column,title=' MENU ')
  draw=widget_draw(lcol, xsize=2*256, ysize=2*256) 
  atext=widget_label(lcol,value='file = '+fname)
  base3 = widget_base(lcol,/row)
   bb=widget_label(base3,value='PS file output: ')
   bbb=widget_text(base3,/editable)
  xpdmenu, [ '"Fields" {','"Bx"','"By"','"Bz"', $
    '"Ex"','"Ey"','"Ez"','}','"Particles" {', $ 
     '"ux"','"uy"','"uz"','"dn"','"pe"','}','"Histogram" {', $ 
     '":x"','":y"','":z"','":vx"','":vy"','":vz"','}', '"Quit"'], rcol
  xmenu, ['Contour','Image_cont','Surface','Shade_surf','Show3', $
    'Plot','Oplot','Histogram'],/exclusive,/Frame,rcol
  mmm=widget_base(rcol,/column)
  mmm1=widget_base(mmm,/row)
  mmm2=widget_base(mmm,/row)
  xmenu, ['tx','xy','yz'],/exclusive,/Frame,mmm1
  xmenu, ['t','x','y','z'],/exclusive,/Frame,mmm1
  xmenu, ['FFT','No FFT'],/exclusive,/Frame,mmm1
  xmenu, ['SHIFT','No SHIFT'],/exclusive,/Frame,mmm2 
  xmenu, ['+','-'],/exclusive,/Frame,mmm2
   base1=widget_base(rcol,/row)
   base2=widget_base(rcol,/row)
   labelx=widget_label(base1,value='    x',/frame)
   list0=widget_list(base1, value=sindgen(ncx), ysize=5)
   labely=widget_label(base1,value='    y',/frame)
   list1=widget_list(base1, value=sindgen(ncy), ysize=5)
   labelz=widget_label(base2,value='    z',/frame)
   list2=widget_list(base2, value=sindgen(ncz), ysize=5)
   labelt=widget_label(base2,value='    t',/frame)
   list3=widget_list(base2, value=sindgen(num+1), ysize=5)
  rrcol= widget_base(rcol,/row)
  w1= widget_button(rrcol, value=' DRAW ')
  w2= widget_button(rrcol, value=' PRINT ')
  widget_control, base, /realize
  widget_control,get_value=window, draw
  wset, window
  xmanager, 'menup', base
  end
