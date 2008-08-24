
pro osiris_analysis_ene, PATH = path, RES = PlotRes,  PSFILE = psfilename, $
                         TMIN = tmin, TMAX = tmax, PSYM = psym, log=iflog



  ; Set floating point exception handling
  temp_except = !Except
  !Except = 2
  
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
  
  ; PSFILE
  ;
  ; Outputs the plot to a PS file
  ;
  ; Set this parameter to the name of the PS you want to output your data to

  if N_Elements(psfilename) eq 0 then useps = 0 $
  else useps = 1
  

  ; RES
  ;
  ; Plot Resolution
  ;
  ; This parameter sets the resolution for the window with the plot. The default
  ; resolution is 1024 x 768 for screen and 10 x 7.5 in for postscript 

  if N_Elements(PlotRes) eq 0 then begin
     if (usePS eq 0) then PlotRes = [1024,768] $
     else PlotRes = [10,7.5]
  end
  
  if (N_Elements(path) eq 0) then begin
    path = dialog_pickfile(Title = 'Choose HIST folder to analyse', /dir)
    if (path eq '') then return
  end

  cd, path

  ; Find Field energy file
  
  fld_ene_fname = findfile('fld_ene', count = nfilesfld)
  
  ; Find particle energy files
  
  par_ene_fnames = findfile('par??_ene', count = nfilespar)
  
  if (nfilesfld+nfilespar eq 0) then begin
    res = error_message('No energy files were found in the specified folder')
    return
  end

  maxcolor = 0l
  init_colors, maxcolor = maxcolor, ct = 0


  ; Open field energy data

  if (nfilesfld ne 0) then begin  
    fld_ene = osiris_open_fld_ene(FILE = fld_ene_fname[0])

    ; Check if sucessfull
    stat = size(fld_ene, /TYPE)
    if (stat ne 8) then return
    
    tote = fld_ene.e1 + fld_ene.e2 + fld_ene.e3
    totb = fld_ene.b1 + fld_ene.b2 + fld_ene.b3
    totemf = tote+totb
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

  ; Open Window / configure PS device
  
  if (useps eq 0) then begin
    window, /free, title = 'Energy History Diagnostics; '+path, $
             Xsize = PlotRes[0], Ysize =PlotRes[1]
    
    !P.Charsize = 2.0 
    !P.Font = -1
  end else begin
    thisDevice = !D.Name
    Set_Plot, 'PS'
    Device, File = psfilename
    Device, Xsize = PlotRes[0], Ysize =PlotRes[1], /Inches
    Device, /landscape
    !P.Charsize = 1.0 
    !P.Font = 1

  end
  
  ; Select Plot distribution

  if (autotmin or autotmax) then avminx = Min(fld_ene.time, Max = avmaxx)  
  
  if (autotmin) then minx = avminx else minx = tmin
  if (autotmax) then maxx = avmaxx else maxx = tmax
  

  !P.Multi = [0,3,3,0,0]  
  
  ; E-Field Energy

  maxy = Max([fld_ene.e1,fld_ene.e2,fld_ene.e3])
  miny = 0.0 
if(Keyword_Set(iflog)) then begin
  plot, [0,1], /nodata, Title = 'E-Field', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1, /ylog  
  oPlot, fld_ene.time, fld_ene.e1, color = MaxColor-1, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.e2, color = MaxColor-2, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.e3, color = MaxColor-3, PSYM = psym 

endif else begin
  plot, [0,1], /nodata, Title = 'E-Field', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1
  oPlot, fld_ene.time, fld_ene.e1, color = MaxColor-1, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.e2, color = MaxColor-2, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.e3, color = MaxColor-3, PSYM = psym

endelse

  ; B-Field Energy
  
  maxy = Max([fld_ene.b1,fld_ene.b2,fld_ene.b3])
  miny = 0.0001 
if(Keyword_Set(iflog)) then begin
  plot, [0,1], /nodata, Title = 'B-Field', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 , /ylog 
endif else begin
  plot, [0,1], /nodata, Title = 'B-Field', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 ;, /ylog 
endelse  
  oPlot, fld_ene.time, fld_ene.b1, color = MaxColor-1, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.b2, color = MaxColor-2, PSYM = psym 
  oPlot, fld_ene.time, fld_ene.b3, color = MaxColor-3, PSYM = psym
  
  ; Total EMF energy

  maxy = Max(totemf)
  miny = 0 

if(Keyword_Set(iflog)) then begin
  plot, fld_ene.time, totemf, Title = 'Total EMF Energy', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1, /ylog 
endif else begin
  plot, fld_ene.time, totemf, Title = 'Total EMF Energy', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1;, /ylog 
endelse
  oPlot, fld_ene.time, tote, color = MaxColor-2, PSYM = psym 
  oPlot, fld_ene.time, totb, color = MaxColor-3, PSYM = psym 
  
  ; Average Kinetic flux plots

  if (autotmin or autotmax) then avminx = Min((*par_ene[0]).time, Max = avmaxx)  
  
  if (autotmin) then minx = avminx else minx = tmin
  if (autotmax) then maxx = avmaxx else maxx = tmax

  
  maxy = Max((*par_ene[0]).q1/((*par_ene[0]).npar > 1), min = miny)
  for i=1, nspec-1 do maxy = Max([(*par_ene[i]).q1/((*par_ene[i]).npar > 1),$
                                   maxy,miny], min = miny)
 

  plot, [0,1], /nodata, Title = 'Average Kinetic Energy Flux along x1', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 

  for i=0, nspec-1 do begin
    oPlot, (*par_ene[i]).time,(*par_ene[i]).q1/((*par_ene[i]).npar>1), color = MaxColor-1-i, PSYM = psym 
  end

;  oPlot, totpar.time,totpar.q1/totpar.npar, color = MaxColor-1-i, $
;         thick = 2.5, PSYM = psym

  maxy = Max((*par_ene[0]).q2/((*par_ene[0]).npar > 1), min = miny)
  for i=1, nspec-1 do maxy = Max([(*par_ene[i]).q2/((*par_ene[i]).npar > 1),$
                                  maxy,miny], min = miny)
 
  plot, [0,1], /nodata, Title = 'Average Kinetic Energy Flux along x2', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 

  for i=0, nspec-1 do begin
    oPlot, (*par_ene[i]).time,(*par_ene[i]).q2/((*par_ene[i]).npar>1), color = MaxColor-1-i, PSYM = psym 
  end

;  oPlot, totpar.time,totpar.q2/totpar.npar, color = MaxColor-1-nspec, $
;         thick = 2.5, PSYM = psym

  maxy = Max((*par_ene[0]).q3/((*par_ene[0]).npar > 1), min = miny)
  for i=1, nspec-1 do maxy = Max([(*par_ene[i]).q3/((*par_ene[i]).npar > 1),$
                                  maxy,miny], min = miny)

  plot, [0,1], /nodata, Title = 'Average Kinetic Energy Flux along x3', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 

  for i=0, nspec-1 do begin
    oPlot, (*par_ene[i]).time,(*par_ene[i]).q3/((*par_ene[i]).npar>1), color = MaxColor-1-i, PSYM = psym 
  end
  
  ;oPlot, totpar.time,totpar.q3/totpar.npar, color = MaxColor-1-nspec, $
  ;       thick = 2.5, PSYM = psym

  ; Total Average kinetic energy flux plots
  
  maxy = Max([totpar.q3/totpar.npar,totpar.q2/totpar.npar, totpar.q1/totpar.npar], min = miny)

  plot, [0,1], /nodata, Title = 'Total Average kinetic energy flux', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 
  
  oPlot, totpar.time, totpar.q1/totpar.npar, color = MaxColor-1, PSYM = psym 
  oPlot, totpar.time, totpar.q2/totpar.npar, color = MaxColor-2, PSYM = psym 
  oPlot, totpar.time, totpar.q3/totpar.npar, color = MaxColor-3, PSYM = psym

  ; Total number of particles

;  maxy = Max(par_ene[*].npar, min = miny)

;  plot, [0,1], /nodata, Title = 'Total Number of particles', yrange =[miny,maxy], $
;        xrange = [minx, maxx], xstyle = 1 

;  for i=0, nspec-1 do begin
;    oPlot, par_ene[i].time,par_ene[i].npar, color = MaxColor-1-i, PSYM = psym 
;  end
  
  
  ; Kinetic energy plots

  maxy = Max((*par_ene[0]).kin, min = miny)
  for i=1, nspec-1 do maxy = Max([(*par_ene[i]).kin,maxy,miny], min = miny)
  
  plot, [0,1], /nodata, Title = 'Particle Kinetic Energy', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1 

  for i=0, nspec-1 do begin
    oPlot, (*par_ene[i]).time, (*par_ene[i]).kin, color = MaxColor-1-i, PSYM = psym 
  end

  ; Energy Conservation
  
  totene = totemf + totpar.kin
  ene_cons = (totene/totene[n_elements(totene)-1] - 1.0)*100.0

  miny = Min(ene_cons, Max = maxy)

  plot, fld_ene.time, ene_cons , Title = 'Energy Conservation [%]', yrange =[miny,maxy], $
        xrange = [minx, maxx], xstyle = 1, PSYM = psym 
  
  ; Closes the PS file if necessary

  if (useps eq 1) then begin
     Device, /Close_File
     Set_Plot, thisDevice
  end

  ptr_free, par_ene  
  !P.Multi = 0
  !Except = temp_except 
  catch, /cancel
  
end
