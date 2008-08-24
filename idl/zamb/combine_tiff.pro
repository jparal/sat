pro combine_tiff, fname, PATH = fpath, DIST = dist, OUTFILE = fileout, OUTPATH = pathout
  

  s = size(fname)
  
  if (s[0] ne 1) then begin
    print, 'Combine_Tiff, fname must be an array with the files to open'
    return  
  end
  nfiles = s[1]
  
  if (nfiles le 1) then begin
    print, 'Combine_Tiff, number of files must be greater than one'
    return
  end

  if (N_Elements(fpath) eq 0) then begin
    fpath = strarr(nfiles)
  end else begin
    s = size(fpath)
    if (s[0] ne 1) or (s[1] ne nfiles) then begin
      print, 'Combine_Tiff, PATH must be an array with the same dimensions as fname'
      return
    end
  end

  if (N_Elements(dist) eq 0) then begin
    dist = [nfiles, 1]
  end else begin
    s = size(dist)
    if (s[0] ne 1) or (s[1] ne 2) then begin
      print, 'Combine_Tiff, DIST must in the form [columns, rows]'
      return
    end
    
    if (dist[0]*dist[1] lt nfiles) then begin
      print, 'Combine_Tiff, DIST[columns, rows], colums*rows must be greater or equal to the'
      print, ' number of files supplied'
      return
    end
    
  end
  
  if (N_Elements(pathout) eq 0) then pathout = fpath[0]
  
  ; Open first file

  print, 'Path->',fpath[0]
  print, 'Name->',fname[0] 
  cd, fpath[0]
  image0 = READ_TIFF(fname[0], ORDER = order) 
  if (order eq 1) then image0 = reverse(image0,3) 
  
  s = size(image0)
  sx = s[2]
  sy = s[3]

  print, 'Image size ', sx, sy


  pImage = PtrArr(nfiles)
  pImage[0] = Ptr_New(image0, /NO_COPY)

  ; Read All the Images

  for i=1, nfiles-1 do begin
    print, fpath[i],fname[i] 
    cd, fpath[i]
    image0 = READ_TIFF(fname[i]) 

    s = size(image0)
    if (sx ne s[2]) or (sy ne s[3]) then begin
      print, 'Combine_Tiff, all images must have the same dimensions'
      ptr_free, pImage
      return
    end

    if (order eq 1) then image0 = reverse(image0,3) 

    pImage[i] = Ptr_New(image0, /NO_COPY)
  end
  
  ; Create the final images

  fimage = BytArr(3, sx*dist[0], sy*dist[1])

  i = 0
  ix = 0
  iy = dist[1] -1
  
  while (i lt nfiles) do begin
    print, 'Processing Image ', i
    print, 'x0, x1', sx*ix,sx*(ix+1)-1
    print, 'y0, y1', sy*iy,sy*(iy+1)-1
        
    fimage[*,sx*ix:sx*(ix+1)-1,sy*iy:sy*(iy+1)-1] = *(pImage[i])
    ix = ix + 1
    if (ix eq dist[0]) then begin
      ix = 0
      iy = iy-1
    end
    
    i = i+1    
  end

  ptr_free, pImage       
  tvimage, fimage 
  fImage = reverse(fImage,3) 
  
  if (N_Elements(fileout) eq 0) then begin
    fileout = Dialog_PickFIle(TITLE = 'Choose Image FIle', /write, filter = '*.tif', get_path = pathout)
  end
  

  cd, pathout  
  if (fileout ne '') then  WRITE_TIFF, fileout, fimage, 1
  

end