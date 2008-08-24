Pro AnaliseDX_3D, dxFileName, TIMEPHYS = _time, TIMESTEP = _timestep, $
                  N=_n,$
                  DATAFILE = _datafile, DATATITLE = _datatitle, $
                  ORIGIN = _origin, $
                  DELTA = _delta
                
  dxData = StrArr(21)
  OpenR, dxFileId, dxFileName, /Get_Lun
  ReadF, dxFileId, dxData  
  Close, dxFileId
  Free_Lun, dxFileId  
  
  temp=Str_Sep(StrCompress(dxData[1]),' ',/trim)
  _time = Double(temp[4])
;  Print, " Simulation Time [1/Wp]  = ", _time

  temp=Str_Sep(StrCompress(dxData[2]),' ',/trim)
  _timestep = Long(temp[7])
;  Print, " Time Step               = ", _timestep

  temp=Str_Sep(StrCompress(dxData[5]),' ',/trim)
  temp2=Str_Sep(temp[4],',')
  _datafile = temp2[0]       
;  Print, " Data File               = ", _datafile


  _n = LONARR(3)

  temp=Str_Sep(StrCompress(dxData[8]),' ',/trim)
  _n[2] = Long(temp[6])
  _n[1] = Long(temp[7])
  _n[0] = Long(temp[8])
;  Print, " Dimensions              = ", _n

  temp=Str_Sep(StrCompress(dxData[18]),'"',/trim)
  _datatitle = temp[1]
;  Print, " Data Name               = ", _datatitle



  _origin = DBLARR(3)
  temp=Str_Sep(StrCompress(dxData[9]),' ',/trim)
  _origin[0] = Double(temp[2])
  _origin[1] = Double(temp[3])
  _origin[2] = Double(temp[4]) 
;   Print, " Origin                  = ", _origin

  _delta = DBLARR(3,3)  
  for i= 0, 2 do begin
   temp=Str_Sep(StrCompress(dxData[10+i]),' ',/trim)
   _delta[2-i,0] = Double(temp[2])
   _delta[2-i,1] = Double(temp[3])
   _delta[2-i,2] = Double(temp[4])  
;   Print, " Delta ", 3-i,_delta[2-i,*]
  end

end