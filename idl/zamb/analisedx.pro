  Pro AnaliseDX,  dxFileName, DIM = _dim, TIMEPHYS = _time, TIMESTEP = _timestep, $
                  N=_n,$
                  DATAFILE = _datafile, DATATITLE = _datatitle, $
                  ORIGIN = _origin, $
                  DELTA = _delta, VERBOSE = _verbose
                  

  ;print, 'AnaliseDX, DX FileName ', dxFileName
  
  if (N_Elements(_verbose) eq 0) then _verbose = 0           
  
  if N_Elements(dxFileName) eq 0 then begin  
     dxfilename=Dialog_Pickfile(FILTER='*.dx')
     if (dxfilename eq '') then return
  end
    
  dxData = StrArr(20)
  OpenR, dxFileId, dxFileName, /Get_Lun
  ReadF, dxFileId, dxData  
  Close, dxFileId
  Free_Lun, dxFileId  
  
  temp=Str_Sep(StrCompress(dxData[1]),' ',/trim)
  _time = Double(temp[4]) 
  if (_verbose gt 0) then  Print, " Simulation Time [1/Wp]  = ", _time

  temp=Str_Sep(StrCompress(dxData[2]),' ',/trim)
  _timestep = Long(temp[7])
  if (_verbose gt 0) then    Print, " Time Step               = ", _timestep

  temp=Str_Sep(StrCompress(dxData[5]),' ',/trim)
  temp2=Str_Sep(temp[4],',')
  _datafile = temp2[0]       
  if (_verbose gt 0) then    Print, " Data File               = ", _datafile


  ; Gets the number of dimensions
  
  temp=Str_Sep(StrCompress(dxData[8]),' ',/trim)

  s = size(temp)
  _dim =s[1]-6
  
  if (_verbose gt 0) then Print, " Number of dimensions     = ", _dim 

  _n = LONARR(_dim)

  for i=0, _dim-1 do begin
   _n[i] = Long(temp[5 + _dim - i ])  
  end

  if (_verbose gt 0) then Print, " Dimensions              = ", _n

  temp=Str_Sep(StrCompress(dxData[15 + _dim]),'"',/trim)
  _datatitle = temp[1]
  if (_verbose gt 0) then    Print, " Data Name               = ", _datatitle

  _origin = DBLARR(_dim)
  temp=Str_Sep(StrCompress(dxData[9]),' ',/trim)
  for i=0, _dim-1 do begin
    _origin[i] = Double(temp[2+i])
  end
   
  if (_verbose gt 0) then Print, " Origin                  = ", _origin

  _delta = DBLARR(_dim,_dim)  
  for i= 0, _dim-1 do begin
   temp=Str_Sep(StrCompress(dxData[10+i]),' ',/trim)
     for j= 0, _dim-1 do begin
       _delta[_dim-1-i,j] = Double(temp[2+j])
     end    
  if (_verbose gt 0) then  Print, " Delta ", 3-i,_delta[_dim-1-i,*]
  end

end