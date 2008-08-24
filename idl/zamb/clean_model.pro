function clean_model, oModel, VERBOSE = verbose
  n_valid_objects = 0
  models = oModel -> Get(/all, COUNT = n_models)
  if (n_models gt 0) then begin
    for i = 0, n_models -1 do begin
      if (obj_isa(models[i], 'IDLgrModel')) then begin
         n_valid_objects = n_valid_objects + clean_model(models[i], VERBOSE = verbose) 
      end else begin
         n_valid_objects = n_valid_objects + 1
      end
    end
  end 
  
  if (keyword_set(verbose)) then begin
    oModel -> GetProperty, UVALUE = name
    name = (N_Elements(name) eq 0)?obj_class(oModel):name
    print, name, ' number of valid elements = ', n_valid_objects  
  end

  if (n_valid_objects eq 0) then obj_destroy, oModel
  return, n_valid_objects
end