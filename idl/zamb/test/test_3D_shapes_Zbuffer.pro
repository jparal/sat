

Set_Plot, 'Z', /Copy
loadct, 1
Device, Set_Resolution = [640,480]


set_shading, gouraud = 1, reject = 1

Erase
Scale3, xrange = [-1,1], yrange =[-1,1], zrange = [-1,1]


; Desenha o Cilindro

;pos0 = [ 0.0, -0.9, -0.9] 
;pos1 = [ 0.0, 0.3, 0.3]
;Cylinder, verts, poly, 30, pos0, pos1, 0.2
;dummy = Polyshade(verts, poly, /t3d)


; Desenha o Cone

;pos0 = pos1
;pos1 = [0.0,0.9,0.9] 
;Cone, verts, poly, 30, pos0, pos1, 0.4
;dummy = Polyshade(verts, poly, /t3d)

; Desenha as esferas

;pos0 = [0.0,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.5
;dummy = Polyshade(verts, poly, /t3d)

;pos0 = [0.5,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.3
;dummy = Polyshade(verts, poly, /t3d)

;pos0 = [-0.5,0.0,0.0]
;Sphere, verts, poly, 30, pos0, 0.3
;dummy = Polyshade(verts, poly, /t3d)


; Desenha o cubo

;pos0 = [0.0,0.0,0.0]
;Cube, verts, poly, pos0, 0.5
;dummy = Polyshade(verts, poly, /t3d)
;plots, verts, /t3d, PSYM = 3 

Np = 1000
NTurns = 8
t = 0.
tinc = NTurns*2*!PI/float(NP-1)

points = fltarr(3,NP)
for i=0, NP-1 do begin
 t = i*tinc
 points[0,i] = 0.5*cos(t)
 points[1,i] = 0.5*sin(t)
 points[2,i] = 1.*i/(NP-1)
 
end

Tube, vert, poly, 10, points, 0.03
dummy = Polyshade(vert, poly, /t3d)

; Visualisation Cube Faces

plots, -1,-1,-1, color = 255, /t3d
plots, -1,-1, 1, /continue, color = 255, /t3d
plots, -1, 1, 1, /continue, color = 255, /t3d
plots, -1, 1,-1, /continue, color = 255, /t3d
plots, -1,-1,-1, /continue, color = 255, /t3d

plots, -1,-1,-1, color = 255, /t3d
plots,  1,-1,-1, color = 255, /t3d, /continue

plots, -1,-1, 1, color = 255, /t3d
plots,  1,-1, 1, color = 255, /t3d, /continue

plots, -1, 1, 1, color = 255, /t3d
plots,  1, 1, 1, color = 255, /t3d, /continue

plots, -1, 1,-1, color = 255, /t3d
plots,  1, 1,-1, color = 255, /t3d, /continue


plots, 1,-1,-1, color = 255, /t3d
plots, 1,-1, 1, /continue, color = 255, /t3d
plots, 1, 1, 1, /continue, color = 255, /t3d
plots, 1, 1,-1, /continue, color = 255, /t3d
plots, 1,-1,-1, /continue, color = 255, /t3d


image = TVRD()

Set_Plot, 'MAC'
window, /free, xsize = 640, ysize = 480
tv, image

print, 'Done!'

end