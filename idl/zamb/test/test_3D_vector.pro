set_plot, 'mac'

NX = 15
NY = 15
NZ = 15

v = fltarr(3,NX,NY,NZ)

XAxisData = -10. + FIndGen(NX)/(NX-1) * 20. 
YAxisData = -10. + FIndGen(NY)/(NY-1) * 20. 
ZAxisData = -10. + FIndGen(NZ)/(NZ-1) * 20. 

pos1 = [-5.,-5.,-5.]
r01 = 10.

pos2 = [+5.,+5.,+5.]
r02 = 7.5


print, 'Generating test data'

for i = 0, NX - 1 do begin
  for j = 0, NY -1 do begin
    for k = 0, NZ -1 do begin
       pos=[XAxisData[i],YAxisData[j],ZAxisData[k]] 
       
       r1 = pos - pos1
       absr1 = sqrt(total(r1*r1)) 
       
       r2 = pos - pos2
       absr2 = sqrt(total(r2*r2)) 
             
       if (absr1 le 0.) then begin 
         v1 = [0.,0.,0.]
       end else v1 = exp(-absr1^2/r01^2)*r1/absr1       
       
       if (absr2 le 0.) then begin 
         v2 = [0.,0.,0.]
       end else v2 = -exp(-absr2^2/r02^2)*r2/absr2       
           
       v[*,i,j,k] = v1 + v2
             
    end
  end
end

print, 'Plotting field'

title = 'Test Data'
subtitle = "Time = " + String(123.456,Format='(f7.2)') + " [ 1 / !Mw!Dp!N ]"
img24 = 0

Plot3Dvector, v, RATIO = [1.,1.,1.], /noiso, RES = 4*[600,600], $
                 XAxis = XAxisData, YAxis = YAxisData, ZAxis = ZAxisData, $
                 TITLE = title, SUBTITLE = subtitle, /track, $
;                 image = img24, antialias = 8,  $
                 /noproj, VOLCT = 25, /render_volume, VOLGLOBALOPAC = byte(255b*0.7)

s = size(img24)
if (s[0] gt 0) then begin
  window, /free, XSIZE = s[2], YSIZE = s[3]
  tvimage, img24
  WRITE_TIFF, 'test.tif', img24
end
end