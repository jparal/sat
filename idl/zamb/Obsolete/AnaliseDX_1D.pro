Pro AnaliseDX_1D, dxFileName, TIMEPHYS = _time, TIMESTEP = _timestep,$
               N=_n,$
               DATAFILE = _datafile, DATATITLE = _datatitle,$
               ORIGIN = _origin, $
               DELTA = _delta
                
  dxData = StrArr(20)
  OpenR, dxFileId, dxFileName, /Get_Lun
  ReadF, dxFileId, dxData  
  Close, dxFileId
  Free_Lun, dxFileId 
 
 print, dxData
  
  temp=Str_Sep(StrCompress(dxData[1]),' ',/trim)
  _time = Double(temp[4])
  Print, " Simulation Time [1/Wp]  = ", _time

  temp=Str_Sep(StrCompress(dxData[2]),' ',/trim)
  _timestep = Long(temp[7])
  Print, " Time Step               = ", _timestep

  temp=Str_Sep(StrCompress(dxData[5]),' ',/trim)
  temp2=Str_Sep(temp[4],',')
  _datafile = temp2[0]                                      
  Print, " Data File               = ", _datafile

  temp=Str_Sep(StrCompress(dxData[8]),' ',/trim)
  _n = Long(temp[6])
  Print, " Dimensions              = ", _n

  temp=Str_Sep(StrCompress(dxData[16]),'"',/trim)
  _datatitle = temp[1]
  Print, " Data Name               = ", _datatitle

  temp=Str_Sep(StrCompress(dxData[9]),' ',/trim)
  _origin = Double(temp[2])
  Print, " Origin                  = ", _origin

  temp=Str_Sep(StrCompress(dxData[10]),' ',/trim)
  _delta = Double(temp[2])

   Print, " Delta ", _delta

end