
; Teste de Object Graphics

; filename=Dialog_Pickfile(FILTER='*.dx')
; if (filename eq '') then stop


; AnaliseDx_3D, filename, DATATITLE = DataName, N = dxN, ORIGIN = dxOrigin, $
;            DELTA = dxDelta,  DATAFILE = datafilename, TIMEPHYS = time

; work_file_id = 1

; close, work_file_id
; OpenR, work_file_id, datafilename
; Header = BytArr(4)
; ReadU, work_file_id, Header
; print ," Dimensions = ", dxN
; print, " Time = ", time, " 1/Wp"
; Data = FltArr(dxN[0],dxN[1],dxN[2])
; ReadU, work_file_id, Data
; Print, "Data read"
; Close, work_file_id

; Data = Data^2 


; thresh1 = 0.5
; thresh2 = 0.9

; vthresh1 = BYTE(thresh1*255)
; vthresh2 = BYTE(thresh2*255)

; MinData = Min(Data, Max = MaxData)

; Data = Smooth(Data,2)
 
; BytData = BytScl(Data)

; Shade_Volume, BytData, vthresh1, vert, poly, /LOW

S = Size(BytData)

; Set up the axis scaling and default rotation

; Scale3, XRange = [0,s[1]], YRange = [0,s[2]], ZRange = [0,s[3]]

; Print, " Data Dimensions :", s
 

; Isosurface

;  Shade_Volume, BytData, vthresh1, vert, poly, /LOW
;  isosurface = PolyShade(vert,poly,/T3D) 
; topColor = !D.Table_Size -2 
;  LoadCT, 0, NColors = topColor+1
;  TV, isosurface



; Poly = Obj_New('IDLgrPolygon', vert)
; Poly -> SetProperty, XCOORD_CONV = [0, 1.0/s[1]], $
;                     YCOORD_CONV = [0, 1.0/s[2]], $
;                     ZCOORD_CONV = [0, 1.0/s[3]] 	
; Poly -> SetProperty, STYLE = 1, Vert_Colors = poly


; Creates a surface

zdata = Dist(40)

surf = Obj_New('IDLgrSurface',zdata)

surf->GetProperty, XRANGE = xr, YRANGE= yr, ZRANGE = zr

surf->SetProperty, XCoord_conv = norm_coord(xr), $
                   YCoord_conv = norm_coord(yr), $
                   ZCoord_conv = norm_coord(zr)

surf -> SetProperty, Style = 2, Shading = 1, Color = [0,200,0], Bottom = [0,250,250] 

; Creates a light

light = Obj_New('IDLgrLight', Type = 1, Location = [1,0,5])


; Create a destination object, in this case a window
Window = Obj_New('IDLgrWindow')

; Create a viewport that fills the entire window
View = Obj_New('IDLgrView')
Model = Obj_New('IDLgrModel') 


Model -> Add, Surf
Model -> Add, light
View  -> Add, Model



Model -> Rotate, [1,0,0], -90
Model -> Rotate, [0,1,0], 30
; Model -> Rotate, [1,0,0], 30


Set_View, View, Window

Window -> Draw, View


END