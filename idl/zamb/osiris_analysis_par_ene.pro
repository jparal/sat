
pro osiris_analysis_par_ene, PATH = path, TMIN = tmin, TMAX = tmax

  
  ; Set Error handling procedure
;  catch, ierror
;  if (ierror ne 0) then begin
;    catch, /cancel
;    ok = Error_Message()
;    return
;  end

  ; TMIN
  ;
  ; Minimum time to display
  
  autotmin = (N_Elements(tmin) eq 0)
  
  ; TMAX
  ;
  ; Minimum time to display
  
  autotmax = (N_Elements(tmax) eq 0)
  
  ; Path
  
  if (N_Elements(path) eq 0) then begin
    path = dialog_pickfile(Title = 'Choose HIST folder to analyse', /dir)
    if (path eq '') then return
  end

  cd, path

  
  ; Find particle energy files
  
  par_ene_fnames = findfile('par??_ene', count = nfilespar)
  
  if (nfilespar eq 0) then begin
    res = Error_message('No particle energy files were found in the specified folder')
    return
  end

  ; Open particle energy files
  
  if (nfilespar gt 0) then begin
    nspec = N_Elements(par_ene_fnames)

    tmp_par_ene = osiris_open_par_ene(FILE = par_ene_fnames[0])
    
    ; Check if sucessfull
    stat = size(tmp_par_ene, /TYPE)
    if (stat ne 8) then return
  
    par_ene = ptr_new(tmp_par_ene, /no_copy)
    totpar = *par_ene
  
    for i = 1, nspec-1 do begin
      tmp_par_ene = osiris_open_par_ene(FILE = par_ene_fnames[i])

      totpar.npar = totpar.npar + tmp_par_ene.npar
      totpar.q1   = totpar.q1   + tmp_par_ene.q1
      totpar.q2   = totpar.q2   + tmp_par_ene.q2
      totpar.q3   = totpar.q3   + tmp_par_ene.q3
      totpar.kin  = totpar.kin  + tmp_par_ene.kin

      par_ene = [par_ene, ptr_new(tmp_par_ene, /no_copy) ]
       
    end
  end
  

  pData = ptrarr(2,nspec+1)
  name = strarr(nspec+1)
    
  for i=0, nspec-1 do begin
    pData[0,i] = ptr_new((*par_ene[i]).time)
    pData[1,i] = ptr_new((*par_ene[i]).q1/double((*par_ene[i]).npar>1)) 
    name[i] = 'Species '+strtrim(i,1)
  end

  pData[0,nspec] = ptr_new(totpar.time)
  pData[1,nspec] = ptr_new(totpar.q1/double(totpar.npar)) 
  name[nspec] = 'Total Particles'

  plot1d, pData, /no_share, TITLE = 'Average Kinetic Energy Flux along x1', name = name, $
      xtitle = 'Time', ytitle = 'Energy Flux', windowtitle = path

    
  for i=0, nspec-1 do begin
    pData[0,i] = ptr_new((*par_ene[i]).time)
    pData[1,i] = ptr_new((*par_ene[i]).q2/double((*par_ene[i]).npar>1)) 
    name[i] = 'Species '+strtrim(i,1)
  end

  pData[0,nspec] = ptr_new(totpar.time)
  pData[1,nspec] = ptr_new(totpar.q2/totpar.npar) 
  name[nspec] = 'Total Particles'

  plot1d, pData, /no_share, TITLE = 'Average Kinetic Energy Flux along x2', name = name, $
      xtitle = 'Time', ytitle = 'Energy Flux', windowtitle = path


  for i=0, nspec-1 do begin
    pData[0,i] = ptr_new((*par_ene[i]).time)
    pData[1,i] = ptr_new((*par_ene[i]).q3/double((*par_ene[i]).npar>1)) 
    name[i] = 'Species '+strtrim(i,1)
  end

  pData[0,nspec] = ptr_new(totpar.time)
  pData[1,nspec] = ptr_new(totpar.q3/double(totpar.npar)) 
  name[nspec] = 'Total Particles'

  plot1d, pData, /no_share, TITLE = 'Average Kinetic Energy Flux along x3', name = name, $
      xtitle = 'Time', ytitle = 'Energy Flux', windowtitle = path


  
end
