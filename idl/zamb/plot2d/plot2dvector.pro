
;--------------------------------------------------------------------------------------------------------------
pro plot2dvector

NX = 100
NY = 100

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


pField = ptrarr(2)

pField[0] = ptr_new(_vx, /no_copy)
pField[1] = ptr_new(_vy, /no_copy)

plot2D, pField, /vector, /no_share

     ; Vector2D, _EXTRA = extrakeys, pVData, oModelVector, XAXIS = xaxisdata, YAXIS = yaxisdata     


ptr_free, pField

END

