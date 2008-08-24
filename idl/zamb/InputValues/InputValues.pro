 
pro InputValues_event,event 

eventName = TAG_NAMES(event, /STRUCTURE_NAME) 


case eventName of
  'WIDGET_BUTTON' : begin
      widget_Control,event.top,get_uvalue=state 

      widget_Control, event.id, get_value = value
      if (value eq 'ok') then begin
        NumEntries = n_tags((*state.data)) 
        for i =0,numEntries-1 do begin ;pull off the values in the fields 
           value = state.fieldIds[i] -> Get_Value()
           (*state.data).(i) = value[0] ;place the values in the pointer 
        endfor
        *state.ok = 1b 
      end else begin
        *state.ok = 0b
      end

      widget_control,event.top,/destroy 
  
   end
  else: print, 'InputValues Event: "',eventName,'"'

endcase

end 
 
function InputValues, $
            data, $					; (IN/OUT)    Structure holding the data
            labels = datalabels, $		; (IN)        Labels for the input fields
            title=title, $				; (IN)        Title for the dialog box
            group_leader=group_leader, $	; (IN)        base widget
            extra_data = extra_data, $	; (IN)        Extra input data (initial value for droplist)
		 XSize = XSize				; (IN)        Size for labels     
 
  if (not Arg_present(data)) then return, -1

  Catch, theError
  IF theError NE 0 THEN BEGIN
     Catch, /Cancel
     ok = Error_Message(!Error_State.Msg)
     RETURN, 0
  ENDIF

 
  NumEntries = n_tags(data) 
  
  if (N_Elements(datalabels) eq 0) then begin
     names = tag_names(data)
  end else begin
     names = datalabels
  end 
  
  if (N_Elements(extra_data) eq 0) then extra_data = LonArr(numEntries)
  
  fieldIds = ObjArr(numEntries) 

  ;Put a label at the top if a title was specified 
  
  if not keyword_set(title) then title = '' 

  if keyword_set(group_leader) then begin
      base = widget_base(/column ,group_leader=group_leader,/modal, tlb_frame_attr = 1, title = title) 
  end else begin
      base = widget_base(/column, tlb_frame_attr = 8+1, title = title)
  end 

  fields_base = widget_base(base, /column, /frame)
  
  ;build a field for every entry in the input structure 

  if (N_elements(XSize) eq 0) then begin
     LabelSize = 75 
  end else begin
     LabelSize = XSize
  end

  for i =numEntries-1,0,-1 do begin 
    if (size(data.(i), /n_dimensions) gt 0) then begin 
             fieldIds[i] = z_droplist(fields_base, title=names[i], data=string(data.(i)),$
                                      value = extra_data[i], LabelSize = LabelSize)
    end else begin
      type = size(data.(i), /type)
      case (type) of
          0: $ ; undefined
             begin
               print, 'Undefined parameter ',names[i],', returning!'
               return, -1b
             end 
          1: $ ;byte is used for boolean values
            fieldIds[i] = z_tglbutton( fields_base, value=data.(i),title=names[i])
          2: $ ;integer
             fieldIds[i] = fsc_inputfield(fields_base,value=data.(i),title=names[i]+' ',$
                                          /IntegerValue, /CR_only, LabelSize = LabelSize) 
          3: $ ;longword integer
             fieldIds[i] = fsc_inputfield(fields_base,value=data.(i),title=names[i]+' ',$
                                          /LongValue, /CR_only, LabelSize = LabelSize) 
          4: $ ;floating pointc
             fieldIds[i] = fsc_inputfield(fields_base,value=data.(i),title=names[i]+' ',$
                                          /FloatValue, /CR_only, LabelSize = LabelSize) 
          5: $ ;double precision
             fieldIds[i] = fsc_inputfield(fields_base,value=data.(i),title=names[i]+' ',$
                                          /DoubleValue, /CR_only, LabelSize = LabelSize) 
        ; 6: complex
          7: $ ;string
             fieldIds[i] = fsc_inputfield(fields_base,value=data.(i),title=names[i]+' ',$ 
                                          /StringValue, /CR_only, LabelSize = LabelSize) 
         ;8: $;structure
         ;9: ;double precision complex
        ;10: ;pointer
        ;11: ;Object Reference
       else: begin
               print, 'Unsupported type, parameter ',names[i],', returning!'
               return, -1b
             end 
      endcase
    end  
  end 

  buttons_base = widget_base(base, /row, /align_right)
  void = widget_button(buttons_base,value='ok', scr_xsize = 50, units = 0) 
  void = widget_button(buttons_base,value='cancel', scr_xsize = 50, units = 0) 
  
  widget_control,base,/realize 
  
  state = { fieldIds : fieldIds, $
            ok       : ptr_new(0b), $
            data     : ptr_new(data) } ;store extra in a pointer so that we can retrieve it later 
  
  widget_control,base,set_uvalue=state 
  
  xmanager,'InputValues',base 
  
  ok = *(state.ok)
  
  if (ok eq 1) then data = (*state.data) ;retrieve the information 
  
  ptr_free,state.data, state.ok ;free the pointers 
  return,ok 
end