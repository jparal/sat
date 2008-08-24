pro load_hdf_palletes, FILE = filename
  
  if N_Elements(filename) eq 0 then begin 
    filename = Dialog_Pickfile(FILTER='*.hdf', TITLE = 'Select HDF pallete file', GET_PATH = temp)
    cd, temp
  end

  npals = HDF_DFP_NPals(filename)
  
  If (npals le 0) then begin
    print, 'No palletes found in file ', filename
    return
  endif
  
  print, npals, ' palettes found'

  palette_names = bytArr(32,24)
  
  palette_names[*,0]  = byte('24-Bit Sampled                  ')
  palette_names[*,1]  = byte('Apricot (Blue->Pink)            ')
  palette_names[*,2]  = byte('Carnation (Red->White)          ')
  palette_names[*,3]  = byte('Ether (Blue->Yellow)            ')
  palette_names[*,4]  = byte('GrayScale                       ')
  palette_names[*,5]  = byte('GrayScale-Banded                ')
  palette_names[*,6]  = byte('GrayScale-Inverted              ')
  palette_names[*,7]  = byte('Hot Metal                       ')
  palette_names[*,8]  = byte('Lava Waves                      ')
  palette_names[*,9]  = byte('Macintosh System Table          ')
  palette_names[*,10] = byte('Malachite (Green->Blue)         ')
  palette_names[*,11] = byte('Morning Glory (Blue->Tan)       ')
  palette_names[*,12] = byte('PeanutButter&Jelly              ')
  palette_names[*,13] = byte('Purple Haze                     ')
  palette_names[*,14] = byte('Rainbow                         ')
  palette_names[*,15] = byte('Rainbow-Banded                  ')
  palette_names[*,16] = byte('Rainbow-High Black              ')
  palette_names[*,17] = byte('Rainbow-Inverted                ')
  palette_names[*,18] = byte('Rainbow-Low Black               ')
  palette_names[*,19] = byte('Rainbow-Striped                 ')
  palette_names[*,20] = byte('Saturn (Pastel Yellow->Purple)  ')
  palette_names[*,21] = byte('Seismic (blue->white->red)      ')
  palette_names[*,22] = byte('Space (Black->Purple->Yellow)   ')
  palette_names[*,23] = byte('Supernova                       ')
  
  
  get_lun, file_id
  OPENW, file_id, 'colors2.tbl'
  writeu, file_id, byte(npals)

  HDF_DFP_Restart
  for i=0, npals-1 do begin
  
    HDF_DFP_GetPal, filename, pal
;    help, pal    
;    print, palette_names[i]
    writeu, file_id, reform(pal[0,*])
    writeu, file_id, reform(pal[1,*])
    writeu, file_id, reform(pal[2,*])
          
  end

  for i=0, npals-1 do begin
    writeu, file_id, palette_names[*,i]
  end

  close, file_id
  free_lun, file_id
  print, 'Done!'
  
end