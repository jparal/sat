;----------------------------------------------------------------------------------------------------
pro depositNGP, part, q, pspace, xmin, xmax, N
  s = size(part)
  print, 'size(part) ', s
  ND = s[2]
  Npart = s[1]
  dx = (xmax - xmin)/(N-1)
  
  case ND of
   1: begin     ; 1D phasespace
        pspace = dblarr(N[0]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0] - xmin[0])/dx[0]
          i = long(nc)         
          if ((i ge 0) and (i le N[0]-1)) then pspace[i] = pspace[i] + q[p]
        end 
      end 
      
   2: begin     ; 2D phasespace
        pspace = dblarr(N[0], N[1]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0:1] - xmin[0:1])/dx[0:1]
          i = long(nc)
         
          if (((i[0] ge 0) and (i[0] le N[0]-1)) and ((i[1] ge 0) and (i[1] le N[1]-1))) $
             then pspace[i[0],i[1]] = pspace[i[0],i[1]] + q[p]
        end 
      end
      
   3: begin     ; 3D phasespace
        pspace = dblarr(N[0], N[1], N[2]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0:2] - xmin[0:2])/dx[0:2]
          i = long(nc)

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and $
              ((i[1] ge 0) and (i[1] le N[1]-1)) and $
              ((i[2] ge 0) and (i[2] le N[2]-1))) then $
               pspace[i[0],i[1],i[2]] = pspace[i[0],i[1],i[2]] + q[p]

        end 
      end
  else: return
  endcase  

end  
;----------------------------------------------------------------------------------------------------



;----------------------------------------------------------------------------------------------------
pro deposit, part, q, pspace, xmin, xmax, N
  s = size(part)
  print, 'size(part) ', s
  ND = s[2]
  Npart = s[1]
  dx = (xmax - xmin)/(N-1)
  
  case ND of
   1: begin     ; 1D phasespace
        pspace = dblarr(N[0]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0] - xmin[0])/dx[0]
          i = long(floor(nc))
          dcx = nc - i
          
          if ((i ge 0) and (i le N[0]-1)) then pspace[i] = pspace[i] + (1.-dcx)*q[p]
          if ((i+1 ge 0) and (i+1 le N[0]-1)) then pspace[i+1] = pspace[i] + dcx*q[p]        
        end 
      end 
      
   2: begin     ; 2D phasespace
        pspace = dblarr(N[0], N[1]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0:1] - xmin[0:1])/dx[0:1]
          i = long(floor(nc))
          dcx = nc - i
          
          ; i,j

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and ((i[1] ge 0) and (i[1] le N[1]-1))) $
             then pspace[i[0],i[1]] = pspace[i[0],i[1]] + (1.-dcx[0])*(1.-dcx[1])*q[p]
             
          ; i+1,j

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and ((i[1] ge 0) and (i[1] le N[1]-1))) $
             then pspace[i[0]+1,i[1]] = pspace[i[0]+1,i[1]] + (dcx[0])*(1.-dcx[1])*q[p]
          
          ; i+1,j+1

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1))) $
             then pspace[i[0]+1,i[1]+1] = pspace[i[0]+1,i[1]+1] + (dcx[0])*(dcx[1])*q[p]

          ; i,j+1

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1))) $
             then pspace[i[0],i[1]+1] = pspace[i[0],i[1]+1] + (1.-dcx[0])*(dcx[1])*q[p]

        end 
      end
      
   3: begin     ; 3D phasespace
        pspace = dblarr(N[0], N[1], N[2]) ; All elements are set to zero by default
        for p=long(0), Npart-1 do begin
          nc = (Part[p,0:2] - xmin[0:2])/dx[0:2]
          i = long(floor(nc))
          dcx = nc - i
          
          ; i,j, k

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and $
              ((i[1] ge 0) and (i[1] le N[1]-1)) and $
              ((i[2] ge 0) and (i[2] le N[2]-1))) then $
               pspace[i[0],i[1],i[2]] = pspace[i[0],i[1],i[2]] + (1.-dcx[0])*(1.-dcx[1])*(1.-dcx[2])*q[p]

          ; i,j, k+1

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and $
              ((i[1] ge 0) and (i[1] le N[1]-1)) and $
              ((i[2]+1 ge 0) and (i[2]+1 le N[2]-1))) then $
               pspace[i[0],i[1],i[2]+1] = pspace[i[0],i[1],i[2]+1] + (1.-dcx[0])*(1.-dcx[1])*(dcx[2])*q[p]
             
          ; i,j+1, k

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and $
              ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1)) and $
              ((i[2] ge 0) and (i[2] le N[2]-1))) then $
               pspace[i[0],i[1]+1,i[2]] = pspace[i[0],i[1]+1,i[2]] + (1.-dcx[0])*(dcx[1])*(1.-dcx[2])*q[p]

          ; i,j+1, k+1

          if (((i[0] ge 0) and (i[0] le N[0]-1)) and $
              ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1)) and $
              ((i[2]+1 ge 0) and (i[2]+1 le N[2]-1))) then $
               pspace[i[0],i[1]+1,i[2]+1] = pspace[i[0],i[1]+1,i[2]+1] + (1.-dcx[0])*(dcx[1])*(dcx[2])*q[p]

          ; i+1,j, k

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and $
              ((i[1] ge 0) and (i[1] le N[1]-1)) and $
              ((i[2] ge 0) and (i[2] le N[2]-1))) then $
               pspace[i[0]+1,i[1],i[2]] = pspace[i[0]+1,i[1],i[2]] + (dcx[0])*(1.-dcx[1])*(1.-dcx[2])*q[p]

          ; i+1,j, k+1

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and $
              ((i[1] ge 0) and (i[1] le N[1]-1)) and $
              ((i[2]+1 ge 0) and (i[2]+1 le N[2]-1))) then $
               pspace[i[0]+1,i[1],i[2]+1] = pspace[i[0]+1,i[1],i[2]+1] + (dcx[0])*(1.-dcx[1])*(dcx[2])*q[p]
             
          ; i+1,j+1, k

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and $
              ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1)) and $
              ((i[2] ge 0) and (i[2] le N[2]-1))) then $
               pspace[i[0]+1,i[1]+1,i[2]] = pspace[i[0]+1,i[1]+1,i[2]] + (dcx[0])*(dcx[1])*(1.-dcx[2])*q[p]

          ; i+1,j+1, k+1

          if (((i[0]+1 ge 0) and (i[0]+1 le N[0]-1)) and $
              ((i[1]+1 ge 0) and (i[1]+1 le N[1]-1)) and $
              ((i[2]+1 ge 0) and (i[2]+1 le N[2]-1))) then $
               pspace[i[0]+1,i[1]+1,i[2]+1] = pspace[i[0]+1,i[1]+1,i[2]+1] + (dcx[0])*(dcx[1])*(dcx[2])*q[p]

        end 
      end
  else: return
  endcase  

end  
;----------------------------------------------------------------------------------------------------


;----------------------------------------------------------------------------------------------------
pro Osiris_Phase_Space, _EXTRA=extrakeys

  pscoord = [ 1 , 2 , 4 ]
  
  sp = 0

  N    = [ 100, 100,  100]
  xmin = [  0.,  0.,  -2.]
  xmax = [ 15., 15.,  +2.]
  NGP = 0
  

  print, 'Opening Particle data...'
  Osiris_Open_Particles, Particles, NUMSPECIES = nspec, SPIDX = spidx, SPNPAR = spnpar

  print, 'Regenerating coordinate system...' 
  s = size(pscoord)
  npscoord = s[1]
  print, 'npscoord ', npscoord
  part = dblarr(spnpar[sp], npscoord)  
  
  q = abs(Particles[spidx[sp]:spnpar[sp]-1].rqm)
  
  for i=0, npscoord-1 do begin
    case pscoord[i] of
     1: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].x[0]
     2: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].x[1]
     3: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].x[2]
     4: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].p[0]
     5: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].p[1]
     6: part[*,i] = Particles[spidx[sp]:spnpar[sp]-1].p[2]
     7: part[*,i] = sqrt(Particles[spidx[sp]:spnpar[sp]-1].p[0]^2 + $
                         Particles[spidx[sp]:spnpar[sp]-1].p[1]^2 + $
                         Particles[spidx[sp]:spnpar[sp]-1].p[2]^2 + 1) - 1
    else: begin
            print, 'ERROR, invalid coordinate for phasespace' 
          end
    endcase
  end
  Particles = 0
  
  XAxisData = FIndGen(N[0])*(xmax[0]-xmin[0])/(N[0]-1) + xmin[0]
  if (npscoord ge 2) then YAxisData = FIndGen(N[1])*(xmax[1]-xmin[1])/(N[1]-1) + xmin[1]
  if (npscoord eq 3) then ZAxisData = FIndGen(N[2])*(xmax[2]-xmin[2])/(N[2]-1) + xmin[2]

  print, 'Depositing particles...'

  if (NGP eq 1) then  depositNGP, part, q, pspace, xmin, xmax, N $
  else depositNGP, part, q, pspace, xmin, xmax, N
  
  print, 'Smoothing phase space...'
  
  pspace = smooth(pspace, 2)
  
  print, 'Ploting result...'  
  
  case npscoord of
    1: plot, pspace, XAXIS = XAxisData, YAXIS = YAXisData, _EXTRA=extrakeys
    2: plot2d, pspace, XAXIS = XAxisData, YAXIS = YAXisData, _EXTRA=extrakeys
    3: plot3d, pspace, XAXIS = XAxisData, YAXIS = YAXisData, ZAXIS = ZAxisData, _EXTRA=extrakeys  
  end
  
  print, 'Done'

end