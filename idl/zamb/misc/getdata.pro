Pro GetData_Events, event

   ; What kind of event is this? We only want to handle button events
   ; from our ACCEPT or CANCEL buttons. Other events fall through.

eventName = Tag_Names(event, /Structure_Name)

IF eventName NE 'WIDGET_BUTTON' THEN RETURN

      ; Get the info structure out of the top-level base

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Which button was selected?

Widget_Control, event.id, Get_Value=buttonValue
CASE buttonValue OF

   'Cancel' : Widget_Control, event.top, /Destroy

   'Accept' : BEGIN

         ; OK, get the information the user put into the form.
         ; Should do error checking, but...maybe later!

      Widget_Control, info.fileID, Get_Value=filename
      Widget_Control, info.xsizeID, Get_Value=xsize
      Widget_Control, info.ysizeID, Get_Value=ysize

         ; Fill out the file data structure with information
         ; collected from the form. Be sure to get just the
         ; *first* filename, since values from text widgets are
         ; always string arrays. Set the CANCEL flag correctly.

      (*info.ptr).filename = filename[0]
      (*info.ptr).xsize = xsize
      (*info.ptr).ysize = ysize
      (*info.ptr).cancel = 0

         ; Destroy the widget program

      Widget_Control, event.top, /Destroy
      END

ENDCASE

END ;*******************************************************************



Function GetData, filename, $           ; Name of file to open.
                  Parent=parent, $      ; Group leader of this program.
                  XSize=xsize, $        ; X Size of file to open.
                  YSize=ysize, $        ; Y Size of file to open.
                  Cancel=cancel         ; An output cancel flag.


   ; This is a pop-up dialog widget to collect the filename and
   ; file sizes from the user. The widget is a modal or blocking
   ; widget. The function result is the image that is read from
   ; the file.
   ;
   ; The Cancel field indicates whether the user clicked the CANCEL
   ; button (result.cancel=1) or the ACCEPT button (result.cancel=0).

 On_Error, 2 ; Return to caller.

   ; Check parameters and keywords.

IF N_Elements(filename) EQ 0 THEN $
   filename=Filepath(Root_Dir=Coyote(),'ctscan.dat') ELSE $
   filename=Filepath(Root_Dir=Coyote(), filename)
IF N_Elements(xsize) EQ 0 THEN xsize = 256
IF N_Elements(ysize) EQ 0 THEN ysize = 256

   ; Position the dialog in the center of the display.

Device, Get_Screen_Size=screenSize
xCenter = FIX(screenSize(0) / 2.0)
yCenter = FIX(screenSize(1) / 2.0)
xoff = xCenter - 150
yoff = yCenter - 150

   ; Create a top-level base. Must have a Group Leader defined
   ; for Modal operation. If this widget is NOT modal, then it
   ; should only be called from the IDL command line as a blocking
   ; widget.

IF N_Elements(parent) NE 0 THEN $
   tlb = Widget_Base(Column=1, XOffset=xoff, YOffset=yoff, $
      Title='Enter File Information...', /Modal, $
      Group_Leader=parent, /Floating, /Base_Align_Center) ELSE $
   tlb = Widget_Base(Column=1, XOffset=xoff, YOffset=yoff, $
      Title='Enter File Information...', /Base_Align_Center)

   ; Make a sub-base for the filename and size widgets.

subbase = Widget_Base(tlb, Column=1, Frame=1)

   ; Create widgets for filename. Set text widget size appropriately.

filesize = StrLen(filename) * 1.25
fileID = CW_Field(subbase, Title='Filename:', Value=filename, $
   XSize=filesize)

   ; Use CW_Fields for the X and Y Size fields. Advantage: You can
   ; make the values integers rather than strings.

xsizeID = CW_Field(subbase, Title='X Size:', Value=xsize, /Integer)
ysizeID = CW_Field(subbase, Title='Y Size:', Value=ysize, /Integer)

   ; Make a button base with frame to hold CANCEL and ACCEPT buttons.

butbase = Widget_Base(tlb, Row=1)
cancel = Widget_Button(butbase, Value='Cancel')
accept = Widget_Button(butbase, Value='Accept')

   ; Realize top-level base and all of its children.

Widget_Control, tlb, /Realize

   ; Create a pointer. This will point to the location where the
   ; information collected from the user will be stored. You must
   ; store it external to the widget program, since the program
   ; will be destroyed no matter which button is selected. Fill the
   ; pointer with NULL values.

ptr = Ptr_New({Filename:'', Cancel:1, XSize:0, YSize:0})

   ; Create info structure to hold information needed in event handler.

info = { fileID:fileID, $     ; Identifier of widget holding filename.
         xsizeID:xsizeID, $   ; Identifier of widget holding xsize.
         ysizeID:ysizeID, $   ; Identifier of widget holding ysize.
         ptr:ptr }            ; Pointer to file information storage location.

   ; Store the info structure in the top-level base

Widget_Control, tlb, Set_UValue=info, /No_Copy

   ; Register the program, set up event loop. Make this program a
   ; blocking widget. This will allow the program to also be called
   ; from IDL command line without a PARENT parameter. The program
   ; blocks here until the entire program is destroyed.

XManager, 'getdata', tlb, Event_Handler='GetData_Events'

  ; OK, widget is destroyed. Go get the file information in the pointer
  ; location, free up pointer memory, and return the file information.

fileInfo = *ptr
Ptr_Free, ptr

  ; All kinds of things can go wrong now. Let's CATCH them all.

Catch, error
IF error NE 0 THEN BEGIN

      ; If an error occurs, set the CANCEL flag, close the LUN if
      ; it is open, and return -1.

   ok = Dialog_Message(!Err_String)
   cancel = 1
   IF N_Elements(lun) NE 0 THEN Free_Lun, lun
   RETURN, -1
ENDIF

   ; If the error flag is set, let's disappear!

cancel = fileInfo.cancel
IF cancel THEN RETURN, -1

   ; OK, try to read the data file. Watch out!

image = BytArr(fileInfo.xsize, fileInfo.ysize)
OpenR, lun, fileInfo.filename, /Get_Lun
ReadU, lun, image
Free_Lun, lun

   ; Hurray! Return the image.

RETURN, image
END ;*******************************************************************
