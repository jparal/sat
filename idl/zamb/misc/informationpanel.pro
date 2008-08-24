 
pro InputValues_event,event 
 
widget_Control,event.top,get_uvalue=state 

widget_Control, event.id, get_value = value
print, value
if (value eq 'ok') then begin
   NumEntries = n_tags((*state.extra)) 
   names = tag_names((*state.extra)) 
   for i =0,numEntries-1 do begin ;pull off the values in the fields 
     value = state.fieldIds[i] -> Get_Value()
     (*state.extra).(i) = value(0) ;place the values in the pointer 
   endfor 
end

widget_control,event.top,/destroy 
end 
 
function InformationPanel,_extra=extra,group_leader=group_leader, $ 
		 title=title 
 
  NumEntries = n_tags(extra) 
  names = tag_names(extra) 
  
  fieldIds = ObjArr(numEntries) 

  ;Put a label at the top if a title was specified 
  
  if not keyword_set(title) then title = '' 

  if keyword_set(group_leader) then begin
      base = widget_base(/column ,group_leader=group_leader,/modal, tlb_frame_attr = 1, title = title) 
  end else begin
      base = widget_base(/column, tlb_frame_attr = 8+1, title = title)
  end 
  
  ;build a field for every entry in the input structure 

  fields_base = widget_base(base, /column, /frame)

  for i =0,numEntries-1 do begin 
    type = (size(extra.(i), /type))[0]
    case (type) of
          0: $ ; undefined
             begin
               print, 'Undefined parameter ',names[i],', returning!'
               return, extra
             end 
          1: $ ;byte is used for boolean values
             fieldIds[i] = z_tglbutton( fields_base, value=extra.(i),title=names[i])
          2: $ ;integer
             fieldIds[i] = fsc_inputfield(fields_base,value=extra.(i),title=names[i]+' ',$
                                          /IntegerValue, /CR_only, LabelSize = 50) 
          3: $ ;longword integer
             fieldIds[i] = fsc_inputfield(fields_base,value=extra.(i),title=names[i]+' ',$
                                          /LongValue, /CR_only, LabelSize = 50) 
          4: $ ;floating pointc
             fieldIds[i] = fsc_inputfield(fields_base,value=extra.(i),title=names[i]+' ',$
                                          /FloatValue, /CR_only, LabelSize = 50) 
          5: $ ;double precision
             fieldIds[i] = fsc_inputfield(fields_base,value=extra.(i),title=names[i]+' ',$
                                          /DoubleValue, /CR_only, LabelSize = 50) 
          ; 6: complex
          7: $ ;string
             fieldIds[i] = fsc_inputfield(fields_base,value=extra.(i),title=names[i]+' ',$ 
                                          /StringValue, /CR_only, LabelSize = 50) 
          ;8: ;structure
          ;9: ;double precision complex
         ;10: ;pointer
         ;11: ;Object Reference
       else: begin
               print, 'Unsupported type, parameter ',names[i],', returning!'
               return, extra
             end 
    endcase  
  endfor 

  buttons_base = widget_base(base, /row)
  void = widget_button(buttons_base,value='ok', scr_xsize = 50, units = 0) 
  void = widget_button(buttons_base,value='cancel', scr_xsize = 50, units = 0) 
  
  widget_control,base,/realize 
  state = { fieldIds : fieldIds, $ 
		  extra : ptr_new(extra) } ;store extra in a pointer so that we can retrieve it later 
  widget_control,base,set_uvalue=state 
  
  xmanager,'InputValues',base 
    
  extra = (*state.extra) ;retrieve the information 
  ptr_free,state.extra ;free the pointer 
  return,extra 
end