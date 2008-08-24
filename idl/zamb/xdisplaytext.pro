pro xdisplaytext_resize_event, sEvent
  Widget_Control, sEvent.top, Get_UValue=sState, /No_Copy
  
  wsx =  sEvent.x -10 
  wsy =  sEvent.y -10 

  Widget_Control, sState.wText, scr_xsize = wsx, scr_ysize = wsy
  
  Widget_Control, sEvent.top, Set_UValue=sState, /No_Copy
end

pro xdisplaytext_event_handler, sEvent

 eventName = TAG_NAMES(sEvent, /STRUCTURE_NAME) 

 case eventName of
  'WIDGET_BASE'  : xdisplaytext_resize_event, sEvent  ; Note: Only resize events are caught here
  
  'WIDGET_BUTTON': 
              
  else: print, 'Event Name: ',eventName
 endcase
end

pro xdisplaytext_cleanup, tlb
  Widget_Control, tlb, Get_UValue=sState, /No_Copy
  if N_Elements(sState) ne 0 then begin     
    ; clean pointer and objects
  end
end

pro xdisplaytext, text, GROUP_LEADER = group_leader, HEIGHT = height, $
             MODAL = modal, TITLE = title, WIDTH = width, NO_BLOCK = no_block
             
  if (N_Elements(text) eq 0) then begin
    res = Error_Message('No text specified!')
    return
  end           
             
  if (N_Elements(height) eq 0) then height = 24           
  
  if (N_Elements(title) eq 0) then title = 'XDisplayText'
  
  if (N_Elements(width) eq 0) then width = 80
  
  modal = keyword_set(modal)
  no_block = keyword_set(no_block)
  
  if (n_elements(group_leader) ne 0) and (modal) then $  
       wbase = widget_base(TITLE = title, /BASE_ALIGN_LEFT, /COLUMN, /MODAL, $
                     GROUP_LEADER = group_leader, /TLB_Size_Events) $
  else $
  wbase = widget_base(TITLE = title, /BASE_ALIGN_LEFT, /COLUMN, $
                     GROUP_LEADER = group_leader, /TLB_Size_Events)
                     
  wtext = widget_text(wbase, xsize = width, ysize = height, /scroll, value = text)
  
  widget_control, wbase, /realize

  sState = { wtext : wtext }
  
  widget_control, wbase, Set_UValue = sState, /no_copy
  
  Xmanager, 'XDisplayText', wbase, $
		event_handler = 'XDisplayText_Event_Handler', $
		cleanup = 'XDisplayText_Cleanup', $
		NO_BLOCK= no_block

end 