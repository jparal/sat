;
  pro menu1d
  common d3fields, abx,aby,abz,$
                    aex,aey,aez,$
                    aux,auy,auz,$
                    adn,ape
  common psout, pslog
  common d3particles, cx,cvx,cvy,cvz,npcl
  common nnn, nx, num
  common f, ff, a,b,c
  common coor, t,x
  common list, list0,list1,listp
  common head, tit, xlab,ylab,zlab
  common util, fft, shift, sign
  common fil, filnam
  common minmax, xmin,xmax,tmin,tmax,xmin1,xmax1,tmin1,tmax1
  common histo, quoi, ih, h
  common psym, p
  filnam='cam.ps'
  pslog=0
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
  hist,cx(0,*),ih,h
  ff=aby
  base = widget_base(title=' Graf CAM 1d ',/row)
  lcol=widget_base(base,/frame, /column)
  rcol=widget_base(base,/frame, /column,title=' MENU ')
  draw=widget_draw(lcol, xsize=2*256, ysize=2*256) 
  atext=widget_label(lcol,value='file = '+fname)
  base3 = widget_base(lcol,/row)
   bb=widget_label(base3,value='PS file output: ')
   bbb=widget_text(base3,/editable)
  xpdmenu, [ '"Fields" {','"Bx"','"By"','"Bz"', $
    '"Ex"','"Ey"','"Ez"','"RH test" {', $
     '"rh1"','"rh2"','"rh3"','"rh4"','"rh5"','"rh6"','}', $
         '}','"Particles" {', $ 
     '"ux"','"uy"','"uz"','"dn"','"pe"','"Phase diagram" {', $
     '"x vx"','"x vy"','"x vz"','"vx vy"','"vy vz"','"vx vz"','}','}',$
      '"Histogram" {', $
     '":x"','":vx"','":vy"','":vz"','}', '"Quit"'], rcol
  xmenu, ['Contour','Image_cont','Image','Surface','Shade_surf','Show3', $
    'Plot','Oplot'],/exclusive,/Frame,rcol
  mmm=widget_base(rcol,/column)
  mmm1=widget_base(mmm,/row)
  mmm2=widget_base(mmm,/row)
  xmenu, ['xmin','xmax','tmin','tmax','CLEAR'],/Frame,mmm1
  xmenu, ['t','x'],/exclusive,/Frame,mmm1
  xmenu, ['FFT','No FFT'],/exclusive,/Frame,mmm1
  xmenu, ['SHIFT','No SHIFT'],/exclusive,/Frame,mmm2 
  xmenu, ['1','2x1','1x2','3x1','1x3','2x2'],/exclusive,/Frame,mmm2
  xmenu, ['+','-'],/exclusive,/Frame,mmm2
   base1=widget_base(rcol,/row)
   base2=widget_base(rcol,/row)
   labelx=widget_label(base1,value='    x',/frame)
   xmin=0
   xmax=nx-1
   xmin1=xmin
   xmax1=xmax
   tmin=0
   tmax=num
   tmin1=tmin
   tmax1=tmax
   list0=widget_list(base1, value=sindgen(nx), ysize=5)
   labelt=widget_label(base2,value='    t',/frame)
   list1=widget_list(base2, value=sindgen(num+1), ysize=5)
   labelp=widget_label(base2,value='    psym',/frame)
   listp=widget_list(base2, value=sindgen(6), ysize=5)
   p=3
  rrcol= widget_base(rcol,/row)
  w1= widget_button(rrcol, value=' DRAW ')
  w2= widget_button(rrcol, value=' PRINT ')
  w3=widget_button(rrcol, value=' COLOR ')
  widget_control, base, /realize
  widget_control,get_value=window, draw
  wset, window
  xmanager, 'menu1d', base
  end
