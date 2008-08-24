
;--------------------------------------------------------------------------------------------------------------
pro plot2dvector, XAXIS = XAxis, YAXIS = YAxis, _EXTRA=extrakeys, TITLE = PlotTitle, SUBTITLE = PlotSubTitle
;--------------------------------------------------------------------------------------------------------------



;-------------------------------------- GENERATE TEST DATA --------------------------------
NX = 21
NY = 21

_vx = FLTARR(NX,NY)
_vy = FLTARR(NX,NY)

for i=0,NX-1 do begin
  for j=0, NY-1 do begin
    x = float(i) - (float(NX)/2.0)
    y = float(j) - (float(NY)/2.0)
    v = exp( - ((x/(float(NX)/4.0))^2 + (y/(float(NY)/4.0))^2))  
    
    t = atan(y,x)
    
    _vx[i,j] = v * sin(t)
    _vy[i,j] = - v * cos(t)
   end
end


;----------------------------------- END GENERATE TEST DATA --------------------------------


; [XY]AXIS
;
; Values for the axis. If not specified the program uses the array indexes

if N_Elements(XAxis) eq 0 then XAxis = FIndGen(NX) 

if N_Elements(YAxis) eq 0 then YAxis = FIndGen(NY)

Erase

PlotPosition = [0.15,0.15,0.90,0.85] 

plot, XAxis, YAxis, xrange = [XAxis[0], XAxis[NX-1]], yrange = [YAxis[0], YAxis[NY-1]],  $
      XSTYLE = 1, YSTYLE = 1, /nodata, _EXTRA=extrakeys, POSITION = plotposition


pvx = ptr_new(_vx)
pvy = ptr_new(_vy)
oplot2Dvector, pvx, pvy, _EXTRA=extrakeys
ptr_free, pvx
ptr_free, pvy


; ------------------------------- Streamlines -----------------------------------------------

num_lines = 0
line_steps = 200
sub_steps = 10

time_step = 1.0/sub_steps

for k =1, num_lines do begin
 
  x = XAxis(randomu(seed) * (nx-1))
  y = YAxis(randomu(seed) * (ny-1)) 
   
  plots, x, y

  for n=1, line_steps do begin
    for m = 1, sub_steps do begin
        
      vel = vel_pos(0.0,[x,y])
      ux = vel[0]
      uy = vel[1]
      
      v = sqrt(ux^2+uy^2)
      
      if (v le 0.) then begin
         goto, loop_end         ; Velocity zero means end of line          
      end
       
      dt = 0.001
      if ((ux ne 0) and (uy ne 0)) then dt = min([dx/(2.0*abs(ux)),dy/(2.0*abs(uy))]) $
      else if (uy eq 0.0) then dt = dx/(2.0*abs(ux)) $
        else dt = dy/(2.0*abs(uy))

      pos = [x,y]
      
      pos = RK4(pos, vel, 0.0, time_step*dt, 'vel_pos', /double)
      
      x = pos[0]
      y = pos[1]
   
      if ((x gt NX-1) or (y gt NY-1)) then begin
         goto, loop_end ; The flow line has left the box
      end 
      
     end    
     plots, x, y, /continue, COLOR = Maxcolor - 1, NOCLIP = 0, THICK = 3

  end
  
loop_end: 

end


; Clears up pallete problems

loadct, 0

END

