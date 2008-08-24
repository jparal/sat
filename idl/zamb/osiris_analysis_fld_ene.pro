pro osiris_analysis_fld_ene, PATH = path, $
                         TMIN = tmin, TMAX = tmax, PSYM = psym, $
                         NO_B = no_b, NO_E = no_e, NO_TOT = no_tot, $
                         ITER = iter, UREF = uref, NORMALIZE = normalize

  if (keyword_set(no_b) and keyword_set(no_e) and keyword_set(no_tot)) then begin
    res = Error_Message('No plots to generate.')
    return
  end
  
  ; TMIN
  ;
  ; Minimum time to display
  
  autotmin = (N_Elements(tmin) eq 0)
  
  ; TMAX
  ;
  ; Minimum time to display
  
  autotmax = (N_Elements(tmax) eq 0)
  
  ; PATH
  
  if (N_Elements(path) eq 0) then begin
    path = dialog_pickfile(Title = 'Choose HIST folder to analyse', /dir)
    if (path eq '') then return
  end

  cd, path

  ; Find Field energy file
  
  if (not file_exists('fld_ene')) then begin
    res = Error_Message('Field Energy file not found.')
    return
  end

  ; open data
  
  fld_ene = osiris_open_fld_ene(FILE = 'fld_ene')

  
  ; Do relativistic correction on the magnetic field
  
  subtitle = ''
  
  if (N_Elements(uref) eq 3) then begin
  
    ; correct time
  
    u = sqrt(total(uref*uref))
    fld_ene.time = fld_ene.time*gamma_of_u(u)
  
    
    ; correct b field ignoring E field    
    
    nsteps = n_elements(fld_ene.time)
    for i=0, nsteps-1 do begin
      b0 = sqrt([fld_ene.b1[i],fld_ene.b2[i],fld_ene.b3[i]])
      e0 = [0,0,0]
    
      lorentz_fld, e0, b0, e1, b1, v_of_u(uref)
    
      fld_ene.b1[i] = b1[0]^2
      fld_ene.b2[i] = b1[1]^2
      fld_ene.b3[i] = b1[2]^2
    end
  
    subtitle = 'Corrected uref = ['+strtrim(uref[0],1)+','+strtrim(uref[1],1)+$
               ','+strtrim(uref[2],1)+']'  
  
    no_b = 0
    no_e = 1
    no_tot = 1
    
  end

  if (keyword_Set(normalize)) then begin
    maxb = max([fld_ene.b1,fld_ene.b2,fld_ene.b3])
    fld_ene.b1 = temporary(fld_ene.b1)/maxb
    fld_ene.b2 = temporary(fld_ene.b2)/maxb
    fld_ene.b3 = temporary(fld_ene.b3)/maxb

    maxe = max([fld_ene.e1,fld_ene.e2,fld_ene.e3])
    fld_ene.e1 = temporary(fld_ene.e1)/maxe
    fld_ene.e2 = temporary(fld_ene.e2)/maxe
    fld_ene.e3 = temporary(fld_ene.e3)/maxe
    
    no_tot =1 
  end

  ; B - Field

  if (not Keyword_Set(no_b)) then begin

  n_series = 3
  pData = ptrarr(2,n_series)

  name = strarr(n_series)
  
  if (Keyword_Set(iter)) then x = fld_ene.iter $
  else x = fld_ene.time
  
  pData[0,0] = ptr_new(x)
  pData[1,0] = ptr_new(fld_ene.b1)
  name[0] = 'B1'

  pData[0,1] = ptr_new(x)
  pData[1,1] = ptr_new(fld_ene.b2)
  name[1] = 'B2'

  pData[0,2] = ptr_new(x)
  pData[1,2] = ptr_new(fld_ene.b3)
  name[2] = 'B3'

;  pData[0,3] = ptr_new(x)
;  pData[1,3] = ptr_new(fld_ene.b1+fld_ene.b2+fld_ene.b3)
;  name[3] = 'Total B'

  plot1D, pData, name = name, /no_share, subtitle = subtitle, $
        Title = 'B-Field',  /ylog, windowtitle = path

  end

  ; E - Field

  if (not Keyword_Set(no_e)) then begin

  n_series = 4

  pData = ptrarr(2,n_series)
  name = strarr(n_series)
  
  pData[0,0] = ptr_new(x)
  pData[1,0] = ptr_new(fld_ene.e1+fld_ene.e2+fld_ene.e3)
  name[0] = 'Total E'

  pData[0,1] = ptr_new(x)
  pData[1,1] = ptr_new(fld_ene.e1)
  name[1] = 'E1'

  pData[0,2] = ptr_new(x)
  pData[1,2] = ptr_new(fld_ene.e2)
  name[2] = 'E2'

  pData[0,3] = ptr_new(x)
  pData[1,3] = ptr_new(fld_ene.e3)
  name[3] = 'E3'

  plot1D, pData, name = name, /no_share, $
        Title = 'E-Field', symbol = psym, $
        XTitle = 'Time', YTitle = 'Energy', /ylog , windowtitle = path  

  end
 
  if (not Keyword_Set(no_tot)) then begin
  
  plot1D, x, fld_ene.e1+fld_ene.e2+fld_ene.e3+fld_ene.b1+fld_ene.b2+fld_ene.b3, $
        Title = 'Total EMF',/ylog, $
        XTitle = 'Time', YTitle = 'Energy', name = 'EM Field' , windowtitle = path    
             
  end
end