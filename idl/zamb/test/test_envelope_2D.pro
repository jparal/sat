pro test_envelope_2D

; 2D testing

;LX = 10.
;LY = 20.
;NX = 300
;NY = 300

;LPX = 4.
;LPY = 4.

;X0 = LX/2
;Y0 = LY/2

;wavelength = 0.5
;p_angle = 3*!PI/4.
;;p_angle = !PI


;kx = 2*!PI/(wavelength) * cos(p_angle)
;ky = 2*!PI/(wavelength) * sin(p_angle)

;x = findgen(NX)*LX/(NX-1)
;y = findgen(NY)*LY/(NY-1)

;field = fltarr(NX,NY)
;for i=0,NX-1 do begin
;  for j = 0, NY-1 do begin
;     field[i,j] = cos(kx*x[i]+ky*y[j])*$             ; fast oscilations
;                  exp(-(x[i] - x0)^2/(LPX/2)^2)*$  ; x modulation
;                  exp(-(y[j] - y0)^2/(LPy/2)^2)    ; y modulation
;  end
;end

osiris_open_data, pfield, FORCEDIMS = 2

pabsfield = ptr_new(abs(*pfield))

plot2D_new, pabsfield, XAXIS = x,YAXIS = y, TITLE = 'Laser Pulse',$
           type = 0, zmax = 12.5, zmin = 0.0, /vert_colors, /add_contour

envelope, pfield, /mirror

plot2D_new, pfield, XAXIS = x,YAXIS = y, TITLE = 'Envelope', $
           type = 0, zmax = 12.5, zmin = 0.0, /vert_colors, /add_contour

end