function gen_k_space_deposit3d,Data,numk,kmax, xrange, yrange, zrange
  s = size(Data)
  
  nx = s[1]
  ny = s[2]
  nz = s[3]
  
  k_space = FltArr(numk)*0.

  deltak = float(kmax)/(float(numk)-1.)

  deltax = (xrange[1]-xrange[0])/(float(nx)-1)
  deltay = (yrange[1]-yrange[0])/(float(ny)-1)
  deltaz = (zrange[1]-zrange[0])/(float(nz)-1)

  print, 'Converting 3D FFT -> k power spectrum'
  print, '-------------------------------------'
  print, 'nx = ', nx
  print, 'ny = ', ny
  print, 'nz = ', nz
  print, 'kmax = ', kmax
  print, 'numk = ', numk
  print, 'xrange = ', xrange
  print, 'yrange = ', yrange
  print, 'zrange = ', zrange
  print, 'deltax = ', deltax
  print, 'deltay = ', deltay
  print, 'deltaz = ', deltaz
  

  for i = 0, nx-1 do begin
    for j = 0, ny-1 do begin
      for l = 0, nz-1 do begin
         kx = xrange[0] + i* deltax
         ky = yrange[0] + j* deltay
         kz = zrange[0] + l* deltaz
         
         k = sqrt(kx^2+ky^2+kz^2)
         
         if (k gt 0) then begin
           nkc = k/deltak    
         
           ik = long(floor(nkc))
           dck = nkc - ik
          
           if ((ik ge 0) and (ik lt numk)) then k_space[ik] = k_space[ik] + (1.-dck)*Data[i,j,l]/k^2
           if ((ik+1 ge 0) and (ik+1 lt numk)) then k_space[ik+1] = k_space[ik+1] + dck*Data[i,j,l]/k^2
         end       
      end
    end
  end
 
  return, k_space
end

function gen_k_space_deposit2d,Data,numk,kmax, xrange, yrange
  s = size(Data)
  
  nx = s[1]
  ny = s[2]
  
  k_space = FltArr(numk)

  deltak = float(kmax)/(float(numk)-1.)

  deltax = (xrange[1]-xrange[0])/(float(nx)-1)
  deltay = (yrange[1]-yrange[0])/(float(ny)-1)
  
  print, 'Converting 2D FFT -> k power spectrum'
  print, '-------------------------------------'
  print, 'nx = ', nx
  print, 'ny = ', ny
  print, 'kmax = ', kmax
  print, 'numk = ', numk
  print, 'xrange = ', xrange
  print, 'yrange = ', yrange
  print, 'deltax = ', deltax
  print, 'deltay = ', deltay

 
  ; Old Code 

  for i = 0, nx-1 do begin
    for j = 0, ny-1 do begin
         kx = xrange[0] + i* deltax
         ky = yrange[0] + j* deltay
         
         k = sqrt(kx^2+ky^2)
         
         if (k gt 0) then begin
           nkc = k/deltak    
         
           ik = long(floor(nkc))
           dck = nkc - ik
          
           if ((ik ge 0) and (ik lt numk)) then k_space[ik] = k_space[ik] + (1.-dck)*Data[i,j]/k
           if ((ik+1 ge 0) and (ik+1 lt numk)) then k_space[ik+1] = k_space[ik+1] + dck*Data[i,j]/k 
         end       
    end
  end

  ; New Code (doesn't work...)
 
;   Data = temporary(reform(Data, nx*ny))
   
;   k_num = sqrt( ((LIndGen(nx*ny) mod nx)*deltax + xrange[0])^2 + $
;                 ((LIndGen(nx*ny)  /  nx)*deltay + yrange[0])^2 )/deltak
                             
;   k_num_i = long(floor(k_num))

;   dck = k_num - k_num_i
  
;   idx = where((k_num_i ge 0) and (k_num_i lt numk) and (k_num gt 0.))
;  
;   k_space[k_num_i[idx]] = temporary(k_space[k_num_i[idx]] + $
;                    (1. - dck[idx]) * deltak* Data[idx]/k_num[idx])

;   idx = where(((k_num_i+1) ge 0) and ((k_num_i+1) lt numk) and (k_num gt 0.))
;  
;   k_space[k_num_i[idx]+1] = temporary(k_space[k_num_i[idx]+1] + $
;                    (dck[idx]) * deltak * Data[idx]/k_num[idx])

;  Data = temporary(reform(Data, nx,ny))
  
  ; clear memory
  
;   idx = 0
;   dck = 0
;   k_num_i = 0
 ;  k_num = 0

 
  return, k_space
end

function gen_k_space_deposit1D,Data,numk,kmax, xrange
  s = size(Data)
  
  nx = s[1]
  
  k_space = FltArr(numk)

  deltak = float(kmax)/(numk-1)

  deltax = (xrange[1]-xrange[0])/(nx-1)
  
; Old Code

;  for i = 0, nx-1 do begin
;         kx = xrange[0] + i* deltax
;         
;         k = sqrt(kx^2)
;         
;         kr = k/deltak    
;         
;         ik = long(floor(kr))
;         dck = kr - ik
;          
;         if ((ik ge 0) and (ik lt numk)) then k_space[ik] = k_space[ik] + (1.-dck)*Data[i]
;         if ((ik+1 ge 0) and (ik+1 lt numk)) then k_space[ik+1] = k_space[ik+1] + dck*Data[i]        
;  end

  k_num = abs(LIndGen(nx)*deltax + xrange[0])/deltak
  dck = k_num - long(floor(k_num))
  k_num = temporary(long(floor(k_num)))

  idx = where(k_num ge 0 and k_num lt numk)
  
  k_space[k_num[idx]] = k_space[k_num[idx]] + $
                   (1. - dck[idx]) * Data[idx] 


  idx = where(k_num+1 ge 0 and k_num+1 lt numk)
  
  k_space[k_num[idx]+1] = k_space[k_num[idx]+1] + $
                   (dck[idx]) * Data[idx] 


  return, k_space
end


pro Osiris_Gen_K_Space, DIRECTORY = DirName, IT0 = t0, IT1 = t1, 
              BACKGROUND = backvalue, DIMS = Dims, DX = Usedx
  
  
; DIRECTORY
;
; The directory holding the data for the frames. If not specified prompts the user for one
;    

if N_Elements(DirName) eq 0 then begin  
  DirName = Dialog_PickFile(/Directory, TITLE = 'Select Data')
  if (DirName eq '') then return
end

CD, DirName


; BACKGROUND
;
; Background value to subtract

if (N_Elements(backvalue) eq 0) then backvalue = 0.0

print, 'Background value to remove, ', backvalue

; DIMS
;
; Dimension of the data to analyse

if N_Elements(Dims) eq 0 then Dims = 3

case (Dims) of
  3:GetOsirisMovieData, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = dxN,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames, $
                    XAXIS = XAxis, YAXIS = YAxis, ZAXIS = ZAxis, DX = Usedx
  2:GetOsirisMovieData2D, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = dxN,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames, $
                    XAXIS = XAxis, YAXIS = YAxis, DX = Usedx
  1:GetOsirisMovieData1D, DIRECTORY = DirName, /Silent, NFRAMES = NFrames, DIMN = dxN,$
                    TIMES = Datatimes, DATANAME = datanames, FILENAME = DataFileNames, $
                    XAXIS = XAxis, DX = Usedx
end


; Generates k-space axis

dxN = reform(dxN[0,*])
deltaX = XAxis[1]-XAxis[0]
N21x = dxN[0]/2 + 1
XAxis = FIndGen(dxN[0])
XAxis[N21x] = N21x - dxN[0] + FINDGEN(N21x - 2)
XAxis = XAxis/(dxN[0]*deltaX)
XAxis = Shift(XAxis, - N21x) 
xrange = [XAxis[0], XAxis[dxN[0]-1] ]

if (Dims ge 2) then begin  
  deltaY = YAxis[1]-YAxis[0]
  N21y = dxN[1]/2 + 1
  YAxis = FIndGen(dxN[1])
  YAxis[N21y] = N21y - dxN[1] + FINDGEN(N21y - 2)
  YAxis = YAxis/(dxN[1]*deltaY)
  YAxis = Shift(YAxis, - N21y) 
  yrange = [YAxis[0], YAxis[dxN[1]-1] ]
end

if (Dims eq 3) then begin
  deltaZ = ZAxis[1]-ZAxis[0]
  N21z = dxN[2]/2 + 1
  ZAxis = FIndGen(dxN[2])
  ZAxis[N21z] = N21z - dxN[2] + FINDGEN(N21z - 2)
  ZAxis = ZAxis/(dxN[2]*deltaZ)
  ZAxis = Shift(ZAxis, - N21z) 
  zrange = [ZAxis[0], ZAxis[dxN[2]-1] ]
end 

case (Dims) of
  3: kmax = Min(Max(Abs([XAxis,YAxis,ZAxis])))
  2: kmax = Min(Max(Abs([XAxis,YAxis])))
  1: kmax = Max(Abs(XAxis))
endcase


;numk = long(Min(dxN/2.))
;numk = long(Max(dxN/2.))
numk = 500

deltak = kmax /(numk -1.)

kaxis = FIndGen(numk)*deltak                     

;for frame=0, NFrames-1 do begin
; for frame=3*NFrames/4, 3*NFrames/4 do begin
for frame = NFrames-1, NFrames-1 do begin

     fname = DataFileNames[frame] 
     print, ' File : ', fname
   
     ; Gets the Data  

     Osiris_Open_Data, Data, FILE = fname, DIM = Dims, TIMEPHYS = time, TIMESTEP = iter, $
                       PATH = DirName, $
                       DATATITLE = DataName, DATALABEL = DataLabel
     
     Data = reform(Data)
     Data = Data - backvalue     
     print, 'Doing FFT...'
     Data = Abs(FFT(Data,-1))
     
     print, 'Generating K - space ...'
     case (Dims) of
       3: begin
            Data = Shift(Data, -N21x, -N21y, -N21z)
            kspace = gen_k_space_deposit3d(Data,numk,kmax, xrange, yrange, zrange)
          end
       2: begin
            Data = Shift(Data, -N21x, -N21y)
            kspace = gen_k_space_deposit2d(Data,numk,kmax,xrange, yrange)
          end
       1: begin
            Data = Shift(Data, -N21x)
            kspace = gen_k_space_deposit1d(Data,numk,kmax,xrange)
          end
     end  
     
     window, /free
     plot, kaxis, kspace, /ylog
     
     outfile = 'kspace_'+ String(byte([ byte('0') +  (iter/10000) mod 10 , $
                                        byte('0') +  (iter/1000)  mod 10 , $
                                        byte('0') +  (iter/100)   mod 10 , $
                                        byte('0') +  (iter/10)    mod 10 , $
                                        byte('0') +  (iter/1)     mod 10 ])) + '.hdf'
                                        
     Osiris_Save_Data, kspace, FILE=outFile, PATH = Dirname, $
                       XAXIS = kAxis, $
                       TIMEPHYS = time, TIMESTEP = iter, $
                       DATATITLE = DataName, DATALABEL = Label, $
                       XNAME = 'k axis', XLABEL = 'k', XUNITS = 'wp / c'  
         
end              

print, 'Done!'

end