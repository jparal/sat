

FUNCTION ShowProgress, Message=message, Title=title, DrawSize=drawsize, $
   ButtonTitle=buttonTitle, XOffset=xoffset, YOffset=yoffset

   ; A function to show the "progress" of a calculation, operation, etc. graphically.
   ; A draw widget will be updated by a moving bar at regular intervals.

   ; MESSAGE: The messageto be placed over the draw widget.
   ; TITLE: The title of the top-level base.
   ; DRAWSIZE: The X size of the draw widget.
   ; BUTTONTITLE: The text that goes on the "cancel" button.
   ; XOFFSET: The x offset of the top-level base.
   ; YOFFSET: The y offset of the top-level base.

   ; Check for keywords

IF N_Elements(message) EQ 0 THEN BEGIN
   message = ''
   testMessage = 0
ENDIF ELSE testMessage=1

IF N_Elements(title) EQ 0 THEN title = ''
IF N_Elements(drawsize) EQ 0 THEN drawsize=100
IF N_Elements(buttonTitle) EQ 0 THEN buttonTitle = 'Cancel Operation...'

   ; Find out how big the display is, so you can position this widget
   ; near the center of the display if offsets are not passed in.

Device, Get_Screen_Size=sizes

IF N_Elements(xoffset) EQ 0 THEN $
   xlocation = (sizes(0) / 2.0) - 75 ELSE xlocation = xoffset
IF N_Elements(yoffset) EQ 0 THEN $
   ylocation = (sizes(1) / 2.0) + 25 ELSE ylocation = yoffset

   ; Define the top-level base. Make it unsizeable.
   ; Give it a title. Make its children centered in it.

tlb = Widget_Base(Column=1, Title=title, TLB_Frame_Attr=1, $
   Base_Align_Center=1, XOffSet=xlocation, YOffSet=ylocation)

   ; If there is a message, make a label to hold it.

IF testMessage NE 0 THEN label = Widget_Label(tlb, Value=message)

   ; Make a draw widget to hold the "progress" bar

draw = Widget_Draw(tlb, XSize=drawsize, YSize=10)

   ; Make a "Cancel Operation" button

cancel = Widget_Button(tlb, Value=buttonTitle)

   ; Realize the widget program.

Widget_Control, tlb, /Realize

   ; Get the window index number of the draw widget

Widget_Control, draw, Get_Value=wid
WSet, wid

   ; Don't call XManager because this program is going to be manaaged
   ; the the calling program using Widget_Event to see if the "Cancel"
   ; button has been clicked. Pass back the X size of the draw widget,
   ; the window index number, the top-level base ID, and the cancel
   ; button ID.

returnValue = {cancel:cancel, wid:wid, drawsize:drawsize, top:tlb}

Return, returnValue
END ;*******************************************************************



PRO CenterTLB, tlb

Device, Get_Screen_Size=screenSize
xCenter = screenSize(0) / 2
yCenter = screenSize(1) / 2

geom = Widget_Info(tlb, /Geometry)
xHalfSize = geom.Scr_XSize / 2
yHalfSize = geom.Scr_YSize / 2

Widget_Control, tlb, XOffset = xCenter-xHalfSize, $
   YOffset = yCenter-yHalfSize

END ;*******************************************************************



Pro Test_Event, event

Widget_Control, event.id, Get_UValue=buttonUValue

CASE buttonUValue OF

   'QUIT': Widget_control, event.top, /Destroy
   'CALC': BEGIN

         ; Call the PROGRESS widget and get it on the screen.
         ; Start by getting the current offsets.

      Widget_Control, event.top, TLB_Get_Offset=offsets
      info = ShowProgress(Message='Performing Large Calculation...', XOffset=offsets(0)+50, $
         YOffset=offsets(1)+50, DrawSize=200, ButtonTitle='Cancel Local Operation')

         ; Set counters. These will indicate how often you want to update
         ; the "progress" display and check for a "cancel operation"
         ; event.

      counter = 10000L
      counterIncrement = 10000L
      percentIncrement = 0.1
      percentDone = 0.0

         ; Set the y coordinates of the red box. These never change

      ybox_coords = [0, 10, 10, 0, 0]

         ; Take over color index 1 to draw a red box in the draw widget

      TVLct, r, g, b, /Get
      oldDrawColor = [r(1), g(1), b(1)]
      TVLct, 255, 0, 0, 1

         ; Go into loop

      For j=0L, 100000L DO BEGIN

            ; This is the place where you do your calculation,
            ; perform your operation, or whatever it is you do.

            ; Calculation .......

            ; This is where you update the "progress" display and
            ; check to see if the "Cancel Operation" button was clicked.

         IF j GT counter THEN BEGIN

               ; Reset counter. Can't be bigger than loop index.

            counter = 100000L < (counter + counterIncrement)
            percentDone = percentDone + percentIncrement

               ; Slow the loop at bit.

             Wait, 1

               ; Update the progress box in the display

               ; Make the draw widget the current window.

            WSet, info.wid

               ; Calculate the extent of the box to be drawn in the draw widget

            xextent = Fix(info.drawsize*percentDone)
            xbox_coords = [0, 0, xextent, xextent, 0]

               ; Draw the box

            Polyfill, xbox_coords, ybox_coords, Color=1, /Device

               ; Did the "Cancel Operation" button get clicked?
               ; Look for an event. Don't turn off the hourglass cursor!

            progressEvent = Widget_Event(info.cancel, /NoWait)

               ; Is this a button event?

            eventName = Tag_Names(progressEvent, /Structure_Name)
            IF eventName EQ 'WIDGET_BUTTON' THEN BEGIN

                   ; If it IS a button event, destroy the widget program and
                   ; issue an informational message to the user to alert him or her.

                Widget_Control, info.top, /Destroy
                result = Widget_Message('Operation Canceled!!', /Information)

                   ; Escape from the loop. Interrupt code would go here.

                GoTo, outSideLoop

             ENDIF

          ENDIF

            ; If the calculation progessed to completion, execute this code.

          IF j EQ 100000L THEN BEGIN

                 ; Make the draw widget the current window.

             WSet, info.wid

                 ; Calculate the extent of the box to be drawn (full box).

              xbox_coords = [0, 0, Fix(info.drawsize), Fix(info.drawsize), 0]

                 ; Draw the box

              Polyfill, xbox_coords, ybox_coords, Color=1, /Device

                 ; Destroy the "show progress" widget program

              Widget_Control, info.top, /Destroy

          ENDIF

       ENDFOR

       outSideLoop: ; Come here when calculation or operation is canceled.

          ; Restore the old colors in color index 1

       TvLct, oldDrawColor(0), oldDrawColor(1), oldDrawColor(2), 1

    END

ENDCASE

END ;*******************************************************************



Pro Test
Device, Decomposed=0
tlb = Widget_Base(Column=1, TLB_Frame_Attr=1)
button = Widget_Button(tlb, Value='Big Calculation', UValue='CALC')
quitter = Widget_Button(tlb, Value='Quit', UValue='QUIT')
CenterTLB, tlb
Widget_Control, tlb, /Realize

XManager, 'Test', tlb
END ;*******************************************************************
