;
;  Program:  
;
;  Osiris_Open_Particles
;
;  Description:
;
;  Opens Osiris particle data 
;
;  Current Version  (31 - Aug - 2000) :
;  
;    0.5 : Fist HDF Working version
;
;  History:
;
; *****************************************************************************************************************
;
; Examples
; ----------------------
;
; Open particle data
;
; > Osiris_Open_Data, pSpecies
;
; Print the charge of particle number 19, of species 3: 
; 
; > print, *pSpecies[2].part[18].q   
; 
; Plot momentum distribution for p3, species 1
;
; > plot,histogram((*pSpecies[0]).part[*].p[2], BINSIZE = 0.01) 
;
; Plot kinetic energy distribution (p^2)
;
; > plot,histogram(total((*pSpecies[0]).part[*].p[*]^2,1), BINSIZE = 0.01) 
;
; Plot p1,x1 phasespace
;
; > plot,(*pSpecies[0]).part[*].x[0],(*pSpecies[0]).part[*].p[0] , PSYM = 3
;
; Arguments
; ----------------------
;
; pSpecies (out)
;
; Array of pointers pointing to the particle data for each species. The data for each species is an
; anonymous structure in the form:
;
; { id:0L, rqm:0D, name:'', num_par:0L, part:REPLICATE(t_particle, num_par) }
; 
; where t_particle is another anonymous structure containing the info for the individual particle
; with the form:
;
; { x:DblArr(xdim), p:DblArr(pdim), q:0D } or
; { x:FltArr(xdim), p:FltArr(pdim), q:0D } 
;
; whether is a single or double precision file
;
; NB: (*pSpecies[i]).part[*].x[*] is an Array[xdim, num_par] 
;
; Parameters
; ----------------------
;  
; FILE (in)
; 
; name of the particle data file. If not supplied the programs prompts the user for one
;
; NUMPAR (out)
;
; returns the total number of particles in the file
;
; NUMSPECIES (out)
;
; returns the total number of species in the file
;
; SPIDX (out)
;
; returns the a vector with NUMSPECIES elements with the indexes of the first particle for each species
;
; SPNPAR (out)
;
; returns the a vector with NUMSPECIES elements with the number of particles in each species
;
; TIME (out)
;
; returns the physical timestep of the file
;
; ITER (out) 
;
; returns the iteration number
;
; NODE (out)
;
; returns the simulation node (note: the first node is node 1)
;
; NGP (out)
;
; returns the node position in the overall simulation box 
;
; ---------------------------------------------------------------------- Main Program -------------

PRO Osiris_Open_Particles, pSpecies, FILE = filename, PATH = path, $
                           NUMPAR = num_particles, NUMSPECIES = num_species, $
                           SPIDX = sp_idx, SPNPAR = sp_npar, SPRQM = sp_rqm, $
                           TIME = time, ITER = iter, NODE = node, $
                           GAMMA_LIMIT = gamma_limit, FRACTION = particle_fraction

If (not Arg_present(pSpecies)) then begin
    newres = Error_Message('Parameter pSpecies must be specified', /Error)
    return
end

; Free pSpecies if allocated
if (ptr_valid(pSpecies))[0] then ptr_free, pSpecies

; Filename

if N_Elements(filename) eq 0 then begin
  filename = Dialog_Pickfile(TITLE = 'Please choose particle data file', $
                             FILTER = '*.hdf', GET_PATH = path)
  if (filename eq '') then return
end

; Path

if (N_Elements(path) eq 0) then path = ''
if (path ne '') then cd, path

print, " Opening Data file..."

; Check for existing file

test = findfile(filename, COUNT = count)
if (count eq 0) then begin
    newres = Error_Message("File not found: "+filename, /Error)
    return
end

; Check if it is an HDF file

if (not HDF_ISHDF(filename)) then begin
    newres = Error_Message("The file "+filename+" is not a proper HDF file.", /Error)
    return
end

; Open HDF File

sdFileID = HDF_SD_Start(filename, /Read)

; Read global attributes

index = HDF_SD_AttrFind(sdFileID, 'TIME')
HDF_SD_ATTRINFO, sdFileID, index, DATA = time
time = time[0]

index = HDF_SD_AttrFind(sdFileID, 'ITER')
HDF_SD_ATTRINFO, sdFileID, index, DATA = iter
iter = iter[0]

index = HDF_SD_AttrFind(sdFileID, 'NODE NUMBER')
HDF_SD_ATTRINFO, sdFileID, index, DATA = node
node = node[0]

index = HDF_SD_AttrFind(sdFileID, 'GAMMA LIMIT')
HDF_SD_ATTRINFO, sdFileID, index, DATA = gamma_limit
gamma_limit = gamma_limit[0]

index = HDF_SD_AttrFind(sdFileID, 'PARTICLE FRACTION')
HDF_SD_ATTRINFO, sdFileID, index, DATA = particle_fraction
particle_fraction = particle_fraction[0]


; Get Number of datasets/particle species

HDF_SD_FileInfo, sdFileID, num_DataSets, num_Attributes

num_species = num_DataSets
sp_idx = LonArr(num_species)
sp_npar = LonArr(num_species)
sp_name = StrArr(num_species)

; Find file type (single or double precision and xdim)
sdsID = HDF_SD_Select(sdFileID, 0)
HDF_SD_GetInfo, sdsID, TYPE = type, DIMS = dims
xdim = dims[0] - 4
HDF_SD_EndAccess, sdsID

; Create Data Structures

pdim = 3
if (type eq 'DOUBLE') then begin
  t_particle = { x:DblArr(xdim), p:DblArr(pdim), q:0D }
end else begin
  t_particle = { x:FltArr(xdim), p:FltArr(pdim), q:0D }
end

pSpecies = ptrarr(num_species)

; Read particles

for i = 0, num_DataSets-1 do begin
  ; Open DataSet
  sdsID = HDF_SD_Select(sdFileID, i)

  ; Get size and name
  HDF_SD_GetInfo, sdsID, DIMS = dims, NAME = name

  sp_npar[i] = dims[1]
  sp_name[i] = name

  ; Get species number
  index =  HDF_SD_AttrFind(sdsID, 'SP_ID')
  HDF_SD_ATTRINFO, sdsID, index, DATA = sp_id_tmp
  sp_idx[i] = sp_id_tmp

  ; Get RQM
  index =  HDF_SD_AttrFind(sdsID, 'RQM')
  HDF_SD_ATTRINFO, sdsID, index, DATA = sp_rqm_tmp
  sp_rqm[i] = sp_rqm_tmp
  

  ; Read Particle Data
  HDF_SD_GetData, sdsID, particle_data

  ; Close Dataset
  HDF_SD_EndAccess, sdsID

  ; Copy Data to Structure
  species = {id:sp_idx[i],	$					; Species ID
             rqm:sp_rqm[i],$					; rqm
             name:sp_name[i], $					; name
             num_par:sp_npar[i], $				; number of particles
             part:REPLICATE(t_particle, sp_npar[i]) $	; particle data
            }

  species.part[*].x[0:xdim-1] = particle_data[0:xdim-1,*]
  species.part[*].p[0:2] = particle_data[xdim:xdim+2,*]
  species.part[*].q = reform(particle_data[xdim+3,*])  
  
  particle_data = 0b
  
  ; Copy structure to pointer array
  pSpecies[i] = ptr_new(species, /no_copy)
    
  print, ' ' 
  print, 'Dataset ',i
  print, '---------------------------------'
  print, 'Name		: ', sp_name[i]
  print, 'ID		: ', sp_id_tmp
  print, 'Particles	: ', sp_npar[i]

;  help, particle_data
end

num_particles = long(total(sp_npar))

print, ' '
print, 'File'
print, '---------------------------------'
print, 'Particles	: ', num_particles
print, 'Type		: ', type

window, /free
plot,(*pSpecies[0]).part[*].x[0],(*pSpecies[0]).part[*].p[0] , PSYM = 3

; Close the file

HDF_SD_End, sdFileID

END