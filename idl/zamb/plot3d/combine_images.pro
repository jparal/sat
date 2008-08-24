function combine_images, img1, img2, TYPE = type
  if not Arg_Present(img1) then return, 0
  if not Arg_Present(img2) then return, img1
  
  ; TYPE
  ;
  ; Type of combination to perform, 0 - max of the two pixels,
  ; 1 - average of the two pixels
  
  if N_elements(type) eq 0 then type = 0
    
  ; Max combination
  
  case (type) of 
     1: begin
          img3 = byte((long(img1) + long(img2))/2.) 
        end
     0: begin
          img3 = (img1 > img2)       
        end
  else: begin
          print, 'combine_images, TYPE value not implemented, returning'
          return, img1
        end   
  end
  
  return, img3
end