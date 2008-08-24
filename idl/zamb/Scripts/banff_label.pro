nscales = 3

pscales = PtrArr(nscales)

; 1st scale

Min = 0.0
Max = 0.972991
Title = 'Magnetic Field'
CT = 25

scale = { type:0, $
          Title:Title, $
          Min:Min, Max:Max, $
          CT:CT }
     
pscales[0] = Ptr_New(scale, /no_copy) 

; 2nd scale

values = [0.5, 0.75, 1.25, 1.5, 1.0]
colors = [[255b,255b,000b,255b], $
          [255b,000b,000b,255b], $
          [000b,255b,255b,255b], $
          [000b,000b,255b,255b], $
          [000b,255b,000b,125b]]

Title = 'Mass Density'

scale = { type:1, $
          Title:Title, $
          Values:Values, Colors:Colors }
     
pscales[1] = Ptr_New(scale, /no_copy) 

; 3rd scale

values = 0.25*[0.75,0.5, 0.25]

colors =  [[255b,000b,000b,255b], $
           [255b,255b,000b,200b], $
           [000b,255b,000b,150b]]

Title = 'EM Energy'

scale = { type:1, $
          Title:Title, $
          Values:Values, Colors:Colors }
     
pscales[2] = Ptr_New(scale, /no_copy) 


; Generate the label

Osiris_Movie_3D_Label, IT0 = 0, $			
                RES = [384,384], $				; Image Resolution
                WINDOWTITLE = 'Test', $	; Window Title
                TITLE1 = '!43D PIC Simulations of the Weibel Instability!3', $			; Main Title
                TITLE2 = 'R. A. Fonseca, UCLA Plasma Simulation Group', $			; Subtitle 1
                TITLE3 = '!4Run:!3 epc003a.3d', $			; Subtitle 2
                SCALES = pscales			; Scales
                
ptr_free, pscales

end