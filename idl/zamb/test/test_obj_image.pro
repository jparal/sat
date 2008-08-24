function image24alpha, Data8bit, CT, alpha
  LoadCT, CT
  TVLCT, rr, gg, bb, /get
  
  s = Size(Data8bit)
  
  ; Old Code
  
  ; AlphaImage = BytArr(4, s1[1], s1[2])
  ; AlphaImage[0,*,*] = rr1(Data1[*,*])
  ; AlphaImage[1,*,*] = gg1(Data1[*,*])
  ; AlphaImage[2,*,*] = bb1(Data1[*,*])
  ; AlphaImage[3,*,*] = 255
  
  ; New Code
  
  AlphaChannel = make_array(size=s, value=alpha)
  help, AlphaChannel
  
  AlphaImage = [rr(Data8bit), gg(Data8bit), bb(Data8bit), AlphaChannel]
  help, AlphaImage
  
  AlphaImage = reform(AlphaImage, s[1], 4, s[2], /overwrite)
  AlphaImage = transpose(AlphaImage, [1,0,2])
  
  return, AlphaImage
  
end


;******************************************** Test Program


Osiris_Open_Data, Data1, DIM = Dims, DIALOGTITLE = 'First Image', /DX
if (Dims eq 0) then stop

Osiris_Open_Data, Data2, DIM = Dims, DIALOGTITLE = 'Second Image', /DX
if (Dims eq 0) then stop

set_plot, 'MAC'
device, decomposed = 1

CT1 = 9
CT2 = 3

print, 'Converting first image to 24 bits...'

s1 = Size(Data1)*3
Data1 = BytScl(Abs(Data1))
Data1 = Rebin(Data1,s1[1],s1[2])

AlphaImage1 = image24alpha(Data1, CT1, 255b)

print, 'Converting second image to 24 bits...'
s2 = Size(Data2)*3
Data2 = BytScl(Abs(Data2))
Data2 = Rebin(Data2,s2[1],s2[2])

AlphaImage2 = image24alpha(Data2, CT2, 128b)


print, 'Generating Objects...'
oWindow = OBJ_NEW('IDLgrWindow', Dimensions=[s1[1],s1[2]])
oView   = OBJ_NEW('IDLgrView', View=[0,0,s1[1],s1[2]], COLOR = [255,255,255])
oModel  = OBJ_NEW('IDLgrModel')

oImage1 = OBJ_NEW('IDLgrImage', AlphaImage1)
oImage1 -> SetProperty, BLEND_FUNCTION = [0,0]

oImage2 = OBJ_NEW('IDLgrImage', AlphaImage2)
oImage2 -> SetProperty, BLEND_FUNCTION = [3,4]

 
oModel -> Add, oImage1
oModel -> Add, oImage2

oView -> Add, oModel
oWindow -> Draw, oView

; TV, AlphaImage, 0.1, 0.1 ,/True, /Normal

end