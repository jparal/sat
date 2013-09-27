pro set_ps, plottype

if plottype eq 'a4landscape' then begin
set_plot,'ps'
device, /landscape, xoffset=1, yoffset=29, xsize=28, ysize=19
endif else if plottype eq 'a4portrait' then begin
set_plot,'ps'
device,/portrait, xoffset=1, yoffset=0, xsize=19, ysize=28
endif else begin
print,'Device string not found'
endelse

end
