Pro AnaliseDX_2D, dxFileName, TIMEPHYS = _time, TIMESTEP = _timestep,$
               N=_n,$
               DATAFILE = _datafile, DATATITLE = _datatitle,$
               ORIGIN = _origin, $
               DELTA = _delta
                
  dxData = StrArr(21)
  OpenR, dxFileId, dxFileName, /Get_Lun
  ReadF, dxFileId, dxData  
  Close, dxFileId
  Free_Lun, dxFileId 
  
  temp=Str_Sep(StrCompress(dxData[1]),' ',/trim)
  _time = Double(temp[4])
;  Print, " Simulation Time [1/Wp]  = ", TIMEPHYS

  temp=Str_Sep(StrCompress(dxData[2]),' ',/trim)
  _timestep = Long(temp[7])
;  Print, " Time Step               = ", TIMESTEP

  temp=Str_Sep(StrCompress(dxData[5]),' ',/trim)
  temp2=Str_Sep(temp[4],',')
  _datafile = temp2[0]                                      
;  Print, " Data File               = ", DATAFILE

  _n = LONARR(2)
  temp=Str_Sep(StrCompress(dxData[8]),' ',/trim)
  _n[1] = Long(temp[6])
  _n[0] = Long(temp[7])
;  Print, " Dimensions              = ", _nx, ",", _ny

  temp=Str_Sep(StrCompress(dxData[17]),'"',/trim)
  _datatitle = temp[1]
;  Print, " Data Name               = ", DATATITLE

  _origin = DBLARR(2)
  temp=Str_Sep(StrCompress(dxData[9]),' ',/trim)
  _origin[0] = Double(temp[2])
  _origin[1] = Double(temp[3])
;  Print, " Origin                  = ", _ORIGIN1, ",", _ORIGIN2

  _delta = DBLARR(2,2)  
  for i= 0, 1 do begin
   temp=Str_Sep(StrCompress(dxData[10+i]),' ',/trim)
   _delta[1-i,0] = Double(temp[2])
   _delta[1-i,1] = Double(temp[3])
;   Print, " Delta ", 2-i,_delta[1-i,*]
  end

end