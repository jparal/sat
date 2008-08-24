
;
;  Program:  
;
;  Osiris_Particles
;
;  Description:
;
;  Opens particle data output from the osiris code and plots it, using color to differentiate
;  particles by energy or species
;
;  Current Version:
;  
;    0.3 - User can now select single species or all species   
;
;  History:
; 
;    0.2 - First Working version. Only first species ploted over energy range 
;    0.1 - Minimum skeleton: reads data, plots particles with no color
;
; ---------------------------------------------------------------------- Main Program -------------


PRO Osiris_Particles, FRACTION = ParticleFraction, PLOTTITLE = Title1, SUBTITLE = Title2, CT = ColorTable, $
                      SPECIES = sp_select, TYPE = PlotType, LABELSPECIES = spLabels, $
                      GAMMAMIN = mingamma


; Minimum kinetic energy to be plotted

if N_Elements(mingamma) eq 0 then mingamma = -1                      
                      
; Default number of spatial dimentions = 2

if N_Elements(x_dim) eq 0 then x_dim = 2

; Default number of momemta dimentions = 3

if N_Elements(p_dim) eq 0 then p_dim = 3

; Default Species Labels

; The default species Labels are defined further below

; Default Plot Type

if N_Elements(PlotType) eq 0 then PlotType = 0

;
; Possible Values for PlotType (determines particle color)
;
; 0 - Kinetic Energy sqrt(|p|^2 + 1) - 1
; 1 - Species
;

; Default Particle Fraction
	
if N_Elements(ParticleFraction) eq 0 then ParticleFraction = 0.02

; Default Species

if N_Elements(sp_select) eq 0 then sp_select = 0 ; All species

; Default Plot Title 
   
if N_Elements(Title1) eq 0 then Title1 = ''

; Default Plot Sub Title
   
if N_Elements(Title2) eq 0 then Title2 = ''

; Default Color Table
   
if N_Elements(ColorTable) eq 0 then ColorTable = 25


osiris_open_particles, pSpecies, 


Print, " Done, analysing species ..."

num_species = MAX (Particles[*].sp_id )

Print, num_species, " species found"

Print, " Done"

case PlotType of
     0: begin
          Print, " Calculating Kinetic Energy"
          ZData = SQRT (Particles[*].p[0]^2 + Particles[*].p[1]^2 + Particles[*].p[2]^2 + 1)-1
        end     
     1: begin
          Print, " Analysing species"
          ZData = Particles[*].sp_id
        end
  else: begin
          Print, " Error, invalid plot type"
          return
        end  
endcase

; Help, Ene

MinZ = Min(ZData)
MaxZ = Max(ZData)

Print, " Z values between [", MinZ, ",", MaxZ, "]"

Print, " Done, Plotting Particles..."

Window, /Free

Device, Get_Visual_Depth = thisDepth
If (thisDepth GT 8) Then Device, Decomposed = 0


XAxis = [MinX,MaxX]
YAxis = [MinY,MaxY]

; Initializes the Display
   
TVLCT, _tr, _tg, _tb, /Get
Erase

numcolors = !D.Table_Size
ImagePosition = [0.15,0.15,0.80,0.85]
BarPosition = [0.85,0.15,0.90,0.85] 
ScaleBarPosition = [0.40,0.15,0.90,0.85]
BoxPosition = [0.85,0.80,0.90,0.85]
DeltaBox = 0.15

; Loads Color Table

LoadCT, ColorTable, NColors = numcolors -1      ;, /Silent

; Creates Color Scale

;print, ZData

BytZ = BytScl(ZData, Max = MaxZ, Min = MinZ, Top = numcolors-2)

; print, BytZ

; stop

case PlotType of
     1: begin
          box_x_coords = [BoxPosition[0],BoxPosition[0],BoxPosition[2],BoxPosition[2],BoxPosition[0]]
          box_y_coords = [BoxPosition[1],BoxPosition[3],BoxPosition[3],BoxPosition[1],BoxPosition[1]]

          boxcolors = BytScl(IndGen(num_species)+1, Max = MaxZ, Min = MinZ, Top = numcolors-2)
          for i=0,num_species-1 do begin  
            ; Print, " Box :", i, " color ", boxcolors[i]
            PolyFill, box_x_coords, box_y_coords, /Normal, $
                     Color = boxcolors[i]
            box_y_coords = box_y_coords - DeltaBox           
           ; PlotS, box_x_coords, box_y_coords, /Normal
          end
          
        end
  else: begin
          colorbar = BytScl(Replicate(1B,20) # BIndGen(256), Top = numcolors-2)
          TVImage , colorbar, Position = BarPosition
        end
endcase

; Prepares plot

Plot, XAxis,YAxis,/NoData,Position = ImagePosition, XStyle = 4, YStyle = 4, $
      /noerase

i=LONG(0)



while (i LT long(num_particles-1)) do begin
  if ((Particles[i].sp_id EQ sp_select) OR (sp_select EQ 0)) then begin
    a = RANDOMU(S)
    
    if (a LT ParticleFraction) then begin 
       if ((mingamma le 0) or $
           (SQRT (Particles[i].p[0]^2 + Particles[i].p[1]^2 + Particles[i].p[2]^2 + 1)-1 ge mingamma)) $
       then $ 
          Plots, Particles[i].x[0],Particles[i].x[1], PSym = 3 , Color = BytZ[i] 
    end
  end
  i = i+1
endwhile

print, ' Final i ', i

; Restores Original Color Table
   
TVLCT, _tr, _tg, _tb

; Plots Spatial Axis Information

Plot, XAxis,YAxis,/NoData,Position = ImagePosition, /noerase


if N_Elements(spLabels) eq 0 then begin
  spLabels = STRING(INDGEN(num_particles)+1, FORMAT = "(I2)")
end
; Plots Color Axis Information
case PlotType of
     1: begin
          box_x_coords = [BoxPosition[0],BoxPosition[0],BoxPosition[2],BoxPosition[2],BoxPosition[0]]
          box_y_coords = [BoxPosition[1],BoxPosition[3],BoxPosition[3],BoxPosition[1],BoxPosition[1]]

          for i=0,num_species-1 do begin  
            PlotS, box_x_coords, box_y_coords, /Normal
            Print, spLabels[i]
            XYOutS, (box_x_coords[2]+DeltaBox / 8), (box_y_coords[0]+DeltaBox / 8), /Normal, $
                    spLabels[i], Alignment = 0.0, CharSize = 1.0
            
            box_y_coords = box_y_coords - DeltaBox           
          end
        end
  else: begin       
          Plot, [0,1], [0,1], /NoData, Position = ScaleBarPosition, /noerase,  $
                XStyle = 4, YStyle = 4   
          Axis, YAxis=1, YRange = [MinZ,MaxZ], YStyle = 1
        end
endcase

; Prints the Labels
   
Label = Title1
XYOutS, 0.5,0.95, /Normal, Label, Alignment = 0.5, CharSize=1.5
Label = Title2
XYOutS, 0.95,0.90, /Normal, Label, Alignment = 1.0, CharSize=1.0


Print, " Done!"
        

END