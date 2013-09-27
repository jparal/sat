pro canplot
set_plot,'ps' & device,/inches, /color, bits=8 ,xsize=7, ysize = 9,xoff=1.0,$
yoff=2.0 , filename='canplot.ps'

!p.multi =[0,2,2]
file = './canopus0327_2.txt'
openr,unit1, file, /get_lun
hamp = fltarr(12)
damp = fltarr(12)
hpha = fltarr(12)
dpha = fltarr(12)
lati = fltarr(12)
nhamp = fltarr(6)
ndamp = fltarr(6)
nhpha = fltarr(6)
ndpha = fltarr(6)
nlati = fltarr(6)
err = fltarr(6)
err2=fltarr(6)
err3=fltarr(6)
err4=fltarr(6)
j = 0L
i = 0L
name = ''
while not eof(unit1) do begin

; GILL   29.97   35.62  179.71    9.64  -81.25   -0.27   -2.62   66.50
readf,unit1, name,time,ham,hphase,dam,dphase,ellip,pol,lat, format='(A4,8f8)'
	hamp[j] = ham
	hpha[j] = hphase
	damp[j] = dam
	dpha[j] = dphase
	lati[j] = lat
rem = (j+1) mod 2 
print,rem
if rem eq 0 then begin
; nhamp[i] = (hamp[j-2]+hamp[j-1]+hamp[j])/3.
; ndamp[i] =  (damp[j-2]+damp[j-1]+damp[j])/3.
; nhpha[i] =(hpha[j-2]+hpha[j-1]+hpha[j])/3.
; ndpha[i] =(dpha[j-2]+dpha[j-1]+dpha[j])/3.
nhamp[i] = (hamp[j-1]+hamp[j])/2.
ndamp[i] =  (damp[j-1]+damp[j])/2.
nhpha[i] =(hpha[j-1]+hpha[j])/2.
ndpha[i] =(dpha[j-1]+dpha[j])/2.
nlati[i] = lati[j]
err[i] = nhamp[i]-hamp[j-1] 
err2[i] = ndamp[i]-damp[j-1]
err3[i] = nhpha[i]-hpha[j-1] 
err4[i] = ndpha[i]-dpha[j-1] 
i = i +1
endif
j = j +1
endwhile

for i = 0, 5 do begin
if nhpha[i] lt -30 then begin
nhpha[i] = nhpha[i] + 360.
endif
endfor
for i = 0, 5 do begin
if ndpha[i] lt 0 then begin
ndpha[i] = ndpha[i] +180.
endif
endfor

!Y.style = 1

plot,nlati,nhamp,position=[0.3,0.6,0.7,0.8],psym = 2,xrange=[55,75],yrange=[0,40],xtitle = 'Latitude (GSM)',ytitle ='Amplitude (nT)'
oplot,nlati,nhamp,linestyle =0
oplot,nlati,ndamp,psym=4
oplot,nlati,ndamp,linestyle =1
ERRPLOT,nlati, nhamp-ERR, nhamp+ERR
ERRPLOT,nlati, ndamp-ERR2, ndamp+ERR2
oplot, [56,58],[35,35],psym=2
oplot, [56,58],[35,35],linestyle =0
xyouts,59,34,'H-comp.',charsize = 1
oplot, [56,58],[30,30],psym=4
oplot, [56,58],[30,30],linestyle =1
xyouts,59,30,'D-comp.',charsize = 1
;plot,lati,hamp,position=[0.1,0.7,0.45,0.9],psym = 2
plot,nlati,nhpha,position=[0.3,0.35,0.7,0.55],psym = 2,xrange=[55,75],yrange=[-50,300],xtitle = 'Latitude (GSM)',ytitle ='Relative phase (degree)'
oplot,nlati,nhpha,linestyle =0
oplot,nlati,ndpha,psym=4
oplot,nlati,ndpha,linestyle =1
ERRPLOT,nlati, nhpha-ERR3, nhpha+ERR3
ERRPLOT,nlati, ndpha-ERR4, ndpha+ERR4
; plot,lati,damp,position=[0.5,0.7,0.85,0.9],psym = 2
; plot,nlati[0:5],ndamp[0:5],position=[0.5,0.7,0.85,0.9],psym = 2
;  plot,lati,dpha,position=[0.3,0.1,0.7,0.3],psym = 2
device,/close_file
close,/all
end

