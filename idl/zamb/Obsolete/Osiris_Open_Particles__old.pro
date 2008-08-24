;
;  Program:  
;
;  Osiris_Open_Particles
;
;  Description:
;
;  Opens Osiris particle data 
;
;  Current Version  (25 - Feb - 2000) :
;  
;    0.1 : Fist Working version
;
;  History:
;
; *****************************************************************************************************************
;
; Parameter list:
;  
; FILE (in)
; 
; name of the particle data file. If not supplied the programs prompts the user for one
;
;
; FORMFILE (in)
;
; Set this keyword to read a formatted file. The default is reading an unformmated file
;
; XDIM (in)
;
; Number of x dimensions of the particle data. The default is 2
;
; PDIM (in)
;
; Number of p dimensions of the particle data. The default is 3
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
; ---------------------------------------------------------------------- Main Program -------------

PRO Osiris_Open_Particles, Particles, FILE = filename, FORMFILE = ReadFormattedFile, XDIM = x_dim, PDIM = p_dim, $
                                      NUMPAR = num_particles, NUMSPECIES = num_species, SPIDX = sp_idx, SPNPAR = sp_npar

                     
; Default number of spatial dimentions = 2

if N_Elements(x_dim) eq 0 then x_dim = 2

; Default number of momenta dimentions = 3

if N_Elements(p_dim) eq 0 then p_dim = 3

; Open a formatted file 

if N_Elements(ReadFormattedFile) eq 0 then ReadFormattedFile=0 

; Filename

if N_Elements(filename) eq 0 then begin
  filename = Dialog_Pickfile(TITLE = 'Please choose particle data file')
  if (filename eq '') then return
end

; sp_id   - 32 bit integer (unsigned?)
; x(:)    - 64 bit double
; p(:)    - 64 bit double
; rqm     - 64 bit double

print, " Opening Data file..."

work_file_id = 1
Close, work_file_id

t_data_particles = { hd1:BYTARR(4),sp_id:0L, x:DBLARR(x_dim), p:DBLARR(p_dim), rqm:0.0D0, hd2:BYTARR(4) }
t_data_particles_size = 4 + 4 + x_dim*8 + p_dim*8 + 8 + 4

if (ReadFormattedFile eq 1) then begin
  OpenR, work_file_id, filename
  fileInfo = FStat(work_file_id)
  if (fileinfo.size eq 0) then begin
     Close, work_file_id
     res = Dialog_Message("The file "+ filename + " is empty.", /Error)
     return
  endif
  OpenW, temp_file_id, '$__temp__$', /Delete, /Get_Lun
  print, eof(work_file_id)  
  while not eof(work_file_id) do begin
     ReadF, work_file_id, t_data_particles.sp_id, t_data_particles.x, t_data_particles.p, t_data_particles.rqm 
     WriteU, temp_file_id, t_data_particles
     Print, t_data_particles
  endwhile
  Close, work_file_id
  Close, temp_file_id
  filename = '$__temp__$'
endif

OpenR, work_file_id, filename 

fileInfo = FStat(work_file_id)
if (fileinfo.size eq 0) then begin
   Close, work_file_id
   res = Dialog_Message("The file " + filename + " is empty.", /Error)
   return
endif

num_particles = long(fileInfo.size) / long(t_data_particles_size)

Particles = REPLICATE(t_data_particles, long(num_particles))
Print, " Reading data..."
ReadU, work_file_id, Particles
Print, " done!"

close, work_file_id

num_species = MAX (Particles[*].sp_id )

sp_idx  = lonarr(num_species)
sp_npar = lonarr(num_species)

i = long(0)
j = Particles[i].sp_id

sp_idx[j-1] = i

while (j lt num_species) do begin
  while (Particles[i].sp_id eq j) do i = i+1 
  j =  j+1
  sp_idx[j-1] = i
end

for i=0,num_species - 2 do begin 
  sp_npar[i] = sp_idx[i+1] - sp_idx[i]
end
sp_npar[num_species - 1] = num_particles - sp_idx[num_species-1] 

print, 'num_particles ', num_particles
print, 'num_species ', num_species
print, 'sp_pos ', sp_idx
print, 'sp_npar ', sp_npar        

END