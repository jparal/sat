pro combine_movie_tiff, ndirs, DIST = dist

  dirnames = strarr(ndirs)

  for i=0, ndirs-1 do begin
    DirName = Dialog_PickFile(/Directory, TITLE = 'Select Data')
    if (DirName eq '') then return
    dirnames[i] = dirname
  end
 
  cd, dirnames[0]
  Filestmp = FindFile(Count = NFiles, '*.tif')

  files = strarr(ndirs, Nfiles)
  files[0,*] = FIlestmp[0:Nfiles-1]
  
  for i=1, ndirs-1 do begin
    cd, dirnames[i]
    Filestmp = FindFile('*.tif')

    files[i,*] = FIlestmp[0:Nfiles-1]
  end
 
  fnames = strarr(ndirs)
  for j=0, NFiles-1 do begin
    print, 'File ',j
    outfile = 'comb_'+String(byte([ byte('0') +  (j/1000.0) mod 10 , $
                             byte('0') +  (j/100.0)  mod 10 , $
                             byte('0') +  (j/10.0)   mod 10 , $
                             byte('0') +  (j/1.0)    mod 10 ])) + ".tif" 
    for i=0, ndirs-1 do begin
       fnames[i] = files[i,j]
       print, 'i,Fname', i, fnames[i]
    end
    help, fnames
    combine_tiff, fnames, PATH = dirnames, DIST = dist, OUTPATH = dirnames[0], OUTFILE = outfile 
    
  end


end


