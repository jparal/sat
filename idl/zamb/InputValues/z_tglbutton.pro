PRO z_tglbutton::MoveTab
IF  NOT Widget_Info(self.tabnext, /Valid_ID) THEN RETURN
Widget_Control, self.tabnext, /Input_Focus
END ;-----------------------------------------------------------------------------------------------------------------------------

PRO z_tglbutton::SetTabNext, nextID
self.tabnext = nextID
END ;-----------------------------------------------------------------------------------------------------------------------------


FUNCTION z_tglbutton::GetButtonID

; This method returns the ID of the button widget of the compound widget.

RETURN, self.buttonID
END ;-----------------------------------------------------------------------------------------------------------------------------


FUNCTION z_tglbutton::GetID

; This method returns the ID of the top-level base of the compound widget.

RETURN, self.tlb
END ;-----------------------------------------------------------------------------------------------------------------------------


FUNCTION z_tglbutton::Geometry

; This method returns the geometry of the compound widget.

RETURN, Widget_Info(self.tlb,/Geometry)
END ;-----------------------------------------------------------------------------------------------------------------------------


FUNCTION z_tglbutton::Get_Value

; This method returns the actual value of the compound widget.

RETURN, self.Value
END ;-----------------------------------------------------------------------------------------------------------------------------


PRO z_tgl__Define

; The FSC_Field Event Structure. Sent only if EVENT_PRO or EVENT_FUNC keywords
; have defined an event handler for the top-level base of the compound widget.

   event = { z_tgl, $         ; The name of the event structure.
             ID: 0L, $            ; The ID of the compound widget's top-level base.
             TOP: 0L, $           ; The widget ID of the top-level base of the hierarchy.
             HANDLER: 0L, $       ; The event handler ID. Filled out by IDL.
             Value: 0b, $         ; the widget value.
             ObjRef:Obj_New()}    ; The "self" object.


END ;-----------------------------------------------------------------------------------------------------------------------------

FUNCTION z_tglbutton::ButtonEvent, event
   ; Error Handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Dialog_Message(!Error_State.Msg)
   RETURN, 0
ENDIF

self.Value = 1 - self.Value

END 

FUNCTION z_tglbutton_Event_Handler, event

; The main event handler for the compound widget. It reacts
; to "messages" in the UValue of the text widget.
; The message indicates which object method to call. A message
; consists of an object method and the self object reference.

Widget_Control, event.ID, Get_UValue=theMessage

event = Call_Method(theMessage.method, theMessage.object, event)

RETURN, event
END ;-----------------------------------------------------------------------------------------------------------------------------


PRO z_tglbutton::GetProperty, $
;
; This method allows you to obtain various properties of the compound widget via output keywords.
;
   Event_Func=event_func, $         ; Set this keyword to the name of an Event Function.
   Event_Pro=event_pro, $           ; Set this keyword to the name of an Event Procedure.
   Name=Name, $                     ; The name of the object.
   UValue=uvalue, $                 ; A user value for any purpose.
   Value=value                      ; The "value" of the compound widget.

   ; Error Handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   ok = Dialog_Message(!Error_State.Msg)
   RETURN
ENDIF

   ; Get the properties.

uvalue = *self.uvalue
value = *self.value           
Name = Self.Name

END ;--------------------------------------------------------------------------------------------------------------


PRO z_tglbutton::SetProperty, $
;
; This method allows you to set various properties of the compound widget.
;
   Event_Func=event_func, $         ; Set this keyword to the name of an Event Function.
   Event_Pro=event_pro, $           ; Set this keyword to the name of an Event Procedure.
   LabelSize=labelsize, $           ; The X screen size of the Label Widget.
   Name=name, $                     ; A scalar string name for the object.
   Title=title, $                   ; The text to go on the Label Widget.
   UValue=uvalue, $                 ; A user value for any purpose.
   Value=value, $                   ; The "value" of the compound widget.

   ; Error Handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   ok = Dialog_Message(!Error_State.Msg)
   RETURN
ENDIF

   ; Set the properties, if needed.

IF N_Elements(event_func) NE 0 THEN self.event_func = event_func
IF N_Elements(event_pro) NE 0 THEN self.event_pro = event_pro

IF N_Elements(labelsize) NE 0 THEN BEGIN
   Widget_Control, self.buttonID, XSize=labelsize
ENDIF

IF N_Elements(title) NE 0 THEN Widget_Control, self.ButtonID, Set_Value=title
IF N_Elements(uvalue) NE 0 THEN *self.uvalue = uvalue
If N_elements(Name) NE 0 Then Self.Name = String(Name[0])

IF N_Elements(value) NE 0 THEN BEGIN
  self.Value = value
  Widget_Control, self.ButtonID, Set_Button=self.Value
ENDIF

END ;--------------------------------------------------------------------------------------------------------------


FUNCTION z_tglbutton::INIT, $       ; The compound widget z_tglbutton INIT method..
   parent, $				; The Parent widget
   Event_Func = event_func, $	; Set this keyword to the name of an Event Function.
   Event_Pro=event_pro, $		; Set this keyword to the name of an Event Procedure. 
   _Extra = extra, $			; Passes along extra keywords to the text widget
   Frame=frame, $                   ; Set this keyword to put a frame around the compound widget.
   LabelFont=labelfont, $		; The font name for the text in the Label Widget.
   LabelSize=labelsize, $		; The X screen size of the Label Widget.
   Title=title, $			; The text to go on the Label Widget.
   UValue=uvalue, $			; A user value for any purpose.
   Value=value, $			; The "value" of the compound widget.
   Name = Name				;The name of the object (a string scalar)

   ; Error Handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   ok = Dialog_Message(!Error_State.Msg)
   RETURN, 0
ENDIF

   ; A parent is required.

IF N_Elements(parent) EQ 0 THEN BEGIN
   Message, 'A PARENT argument is required. Returning...', /Informational
   RETURN, -1L
ENDIF

   ; Check keyword values.

IF N_Elements(event_func) EQ 0 THEN event_func = ""
IF N_Elements(event_pro) EQ 0 THEN event_pro = ""
IF N_Elements(frame) EQ 0 THEN frame = 0
IF N_Elements(labelfont) EQ 0 THEN labelfont = ""
IF N_Elements(labelsize) EQ 0 THEN labelsize = 0
IF N_Elements(title) EQ 0 THEN title = "On / Off"
IF N_Elements(uvalue) EQ 0 THEN uvalue = ""
IF N_Elements(value) EQ 0 THEN value = 0b

   ; Populate the object.

self.parent = parent
self.event_pro = event_pro
self.event_func = event_func
self.uvalue = Ptr_New(uvalue)
If N_elements(Name) NE 0 Then Self.Name = String(Name[0])

   ; Validate the input value.

if (value ne 0) and (value ne 1) then value = 0
self.value = value

   ; Create the widgets.

self.tlb = Widget_Base( parent, $  ; The top-level base of the compound widget.
   Frame=frame, $
   /column, $
   /nonexclus, $
   /Base_Align_Center, $
   UValue=uvalue, $
   Event_Pro=event_pro, $
   Event_Func=event_func )

self.buttonID = Widget_Button( self.tlb, $
   Value = title, $
   Font=labelfont, $ 
   Scr_XSize=labelsize, $
   UValue = {Method:'ButtonEvent', Object:self}, $
   Event_Func='z_tglbutton_Event_Handler', $
   Kill_Notify = 'z_tglbutton_kill_notify'$
   )

widget_control, self.buttonID, Set_Button = self.value 

RETURN, 1
END ;--------------------------------------------------------------------------------------------------------------

PRO z_tglbutton_Kill_Notify, buttonID

; This widget call-back procedure makes sure the self object is
; destroyed when the widget is destroyed.

Widget_Control, buttonID, Get_UValue=message
Obj_Destroy, message.object
END ;--------------------------------------------------------------------------------------------------------------


PRO z_tglbutton::CLEANUP

; This method makes sure there are not pointers left on the heap.

Ptr_Free, self.uvalue
END ;--------------------------------------------------------------------------------------------------------------


PRO z_tglbutton__Define

   objectClass = { z_tglbutton, $           ; The object class name.
                   parent: 0L, $            ; The parent widget ID.
                   tlb: 0L, $               ; The top-level base of the compound widget.
                   buttonID: 0L, $          ; The button ID
                   value:0b, $              ; The button state (0 - off, 1 - on)
                   labelID: 0L, $           ; The label widget ID.
                   event_func: "", $        ; The name of the specified event handler function.
                   event_pro: "", $         ; The name of the specified event handler procedrue
                   tabnext: 0L, $           ; The identifier of a widget to receive the cursor focus if a TAB character is detected.
                   uvalue: Ptr_New(), $     ; The user value of the compound widget.
                   Name:"" $        ; a scalar string name for the object
                  }

END ;--------------------------------------------------------------------------------------------------------------


function z_tglbutton, $
   parent, $				; The Parent widget
   Event_Func = event_func, $	; Set this keyword to the name of an Event Function.
   Event_Pro=event_pro, $		; Set this keyword to the name of an Event Procedure. 
   _Extra = extra, $			; Passes along extra keywords to the text widget
   Frame=frame, $                   ; Set this keyword to put a frame around the compound widget.
   LabelFont=labelfont, $		; The font name for the text in the Label Widget.
   LabelSize=labelsize, $		; The X screen size of the Label Widget.
   Title=title, $			; The text to go on the Label Widget.
   UValue=uvalue, $			; A user value for any purpose.
   Value=value, $			; The "value" of the compound widget.
   Name = Name				;The name of the object (a string scalar)
   
   
 return, Obj_New("Z_TGLBUTTON", $
   parent, $				; The Parent widget
   Event_Func = event_func, $	; Set this keyword to the name of an Event Function.
   Event_Pro=event_pro, $		; Set this keyword to the name of an Event Procedure. 
   _Extra = extra, $			; Passes along extra keywords to the text widget
   Frame=frame, $                   ; Set this keyword to put a frame around the compound widget.
   LabelFont=labelfont, $		; The font name for the text in the Label Widget.
   LabelSize=labelsize, $		; The X screen size of the Label Widget.
   Title=title, $			; The text to go on the Label Widget.
   UValue=uvalue, $			; A user value for any purpose.
   Value=value, $			; The "value" of the compound widget.
   Name = Name)				;The name of the object (a string scalar)
end
		