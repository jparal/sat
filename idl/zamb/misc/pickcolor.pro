

;+
; NAME:
;       PICKCOLOR
;
; PURPOSE:
;
;       A modal dialog widget allowing the user to select
;       the RGB color triple specifying a color. The return
;       value of the function is the color triple specifying the
;       color or the "name" of the color if the NAME keyword is set.
;
; AUTHOR:
;       FANNING SOFTWARE CONSULTING:
;       David Fanning, Ph.D.
;       2642 Bradbury Court
;       Fort Collins, CO 80521 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, Color Specification. See related program GETCOLOR.
;
; CALLING SEQUENCE:
;
;       color = PickColor(colorindex)
;
; RETURN VALUE:
;
;       The return value of the function is a 1-by-3 array containing
;       the values of the color triple that specifies the selected color.
;       The color can be loaded, for example, in any color index:
;
;           color = PickColor(240)
;           TVLCT, color, 240
;
;       The return value is the original color triple if the user
;       selects the CANCEL button.
;
;       IF the NAME keyword is set, the return value of the function is
;       the "name" of the selected color. This would be appropriate for
;       passing to the GetColor program, for example.
;
; OPTIONAL INPUT POSITIONAL PARAMETERS:
;
;       COLORINDEX: The color index of the color to be changed. If not
;              specified the color index !D.Table_Size - 2 is used.
;              The Current Color and the Color Sliders are set to the
;              values of the color at this color index.
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;       GROUP_LEADER: The group leader for this widget program. This
;              keyword is required for MODAL operation. If not supplied
;              the program is a BLOCKING widget. Be adviced, however, that
;              the program will NOT work if called from a blocking widget
;              program, unless a GROUP_LEADER is supplied.
;
;       NAMES: Set this keyword to return the "name" of the selected color
;              rather than its color triple.
;
;       STARTINDEX: Sixteen pre-determined colors are loaded The STARTINDEX
;              is the index in the color table where these 16 colors will
;              be loaded. By default, it is !D.Table_Size - 17.
;
;       TITLE: The title on the program's top-level base. By default the
;              title is "Pick a Color".
;
; OPTIONAL INPUT KEYWORD PARAMETERS:
;
;       CANCEL: A keyword that is set to 1 if the CANCEL button is selected
;              and to 0 otherwise.
;
; COMMON BLOCKS:
;
;       None.
;
; SIDE EFFECTS:
;
;       Sixteen pre-determined colors are loaded in the color table.
;       In addition, the color index at COLORINDEX is modified while
;       the program is on the display. When the program exits, the
;       entry color table is restored. Thus, on 8-bit displays there
;       might be some color effects in graphics windows while PICKCOLOR
;       is on the display. Changes in the color table are not noticable
;       on 16-bit and 24-bit displays.
;
; EXAMPLE:
;
;       To specify a color for a plot in color decomposition OFF mode:
;
;          Device, Decomposed=0
;          !P.Color = !P.Color < (!D.Table_Size - 1)
;          color = PickColor(!P.Color, Cancel=cancelled)
;          IF NOT cancelled THEN BEGIN
;             TVLCT, color, !P.Color
;              Plot, data
;          ENDIF
;
;       To specify a color for a plot in color decomposition ON mode:
;
;          Device, Decomposed=1
;          color = PickColor(Cancel=cancelled)
;          !P.Color = Color24(color)
;          IF NOT cancelled THEN Plot, data
;
;        To obtain the name of the selected color to pass to GetColor:
;
;          selectedColor = PickColor(/Name)
;          axisColor = GetColor(selectedColor, !D.Table_Size-4)
;
; MODIFICATION HISTORY:
;       Written by: David Fanning, 28 Oct 99.
;       Added NAME keyword. 18 March 2000, DWF.
;       Fixed a small bug when choosing a colorindex less than !D.Table_Size-17. 20 April 2000. DWF.
;       Added actual color names to label when NAMES keyword selected. 12 May 2000. DWF.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2000 Fanning Software Consulting.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


PRO PickColor_CenterTLB, tlb

Device, Get_Screen_Size=screenSize
xCenter = screenSize(0) / 2
yCenter = screenSize(1) / 2

geom = Widget_Info(tlb, /Geometry)
xHalfSize = geom.Scr_XSize / 2
yHalfSize = geom.Scr_YSize / 2

Widget_Control, tlb, XOffset = xCenter-xHalfSize, $
   YOffset = yCenter-yHalfSize
END ;---------------------------------------------------------------------------



PRO PickColor_Select_Color, event

; This event handler permits color selection by clicking on a color window.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Get the color names from the window you clicked on.

Widget_Control, event.id, Get_UValue=thisColorName

IF info.needsliders EQ 0 THEN Widget_Control, info.labelID, Set_Value=thisColorName

   ; Get the color value and load it as the current color.

WSet, info.currentWID
thisColor = GetColor(thisColorName)
info.currentName = thisColorName
TVLCT, thisColor, info.currentColorIndex
PolyFill, [0,0,1,1,0], [0,1,1,0,0], /Normal, Color=info.currentColorIndex

IF info.needSliders THEN BEGIN

      ; Update the slider values to this color value.

   Widget_Control, info.redID, Set_Value=thisColor[0,0]
   Widget_Control, info.greenID, Set_Value=thisColor[0,1]
   Widget_Control, info.blueID, Set_Value=thisColor[0,2]

ENDIF

Widget_Control, event.top, Set_UValue=info, /No_Copy
END ;---------------------------------------------------------------------------


PRO PickColor_Sliders, event

; This event handler allows the user to mix their own color.

Widget_Control, event.top, Get_UValue=info, /No_Copy

   ; Get the color slider values.

Widget_Control, info.redID, Get_Value=red
Widget_Control, info.greenID, Get_Value=green
Widget_Control, info.blueID, Get_Value=blue

   ; Load the new color as the current color.

WSet, info.currentWID
TVLCT, red, green, blue, info.currentColorIndex
PolyFill, [0,0,1,1,0], [0,1,1,0,0], /Normal, Color=info.currentColorIndex

Widget_Control, event.top, Set_UValue=info, /No_Copy
END ;---------------------------------------------------------------------------



PRO PickColor_Buttons, event

; This event handler responds to CANCEL and ACCEPT buttons.

Widget_Control, event.top, Get_UValue=info, /No_Copy
Widget_Control, event.id, Get_Value=buttonValue
CASE buttonValue OF

   'Cancel': BEGIN
      TVLCT, info.r_old, info.g_old, info.b_old ; Restore old color table.
      Widget_Control, event.top, /Destroy       ; Exit.
      ENDCASE

   'Accept': BEGIN
      TVLCT, r, g, b, /Get ; Get the new color table.
      TVLCT, info.r_old, info.g_old, info.b_old ; Restore old color table.

         ; Save the new color in the form info pointer.

      *(info.ptr) = {cancel:0.0, r:r[info.currentColorIndex], g:g[info.currentColorIndex], $
         b:b[info.currentColorIndex], name:info.currentName}
      Widget_Control, event.top, /Destroy ; Exit

      ENDCASE
ENDCASE
END ;---------------------------------------------------------------------------



FUNCTION PickColor, currentColorIndex, StartIndex=startIndex, Title=title, $
   Group_Leader=groupLeader, Cancel=cancelled, Names=name

   ; Device must support windows.

IF (!D.FLAGS AND 256) EQ 0 THEN BEGIN
   Message, 'Device must support windows. Returning...', /Continue
   cancelled = 1
   RETURN, -1
ENDIF

   ; Working in decomposed color space with defined number of colors.
   ; Save decomposed state and restore it, if possible.

IF Float(!Version.Release) GE 5.2 THEN BEGIN
   Device, Get_Decomposed=decomposedState
ENDIF ELSE decomposedState = 0

Device, Decomposed=0
NCOLORS = 16

   ; Check parameters.

IF N_Elements(title) EQ 0 THEN title = 'Pick a Color'
IF N_Elements(startIndex) EQ 0 THEN startIndex = !D.Table_Size - (NCOLORS + 1)
startIndex = startIndex < (!D.Table_Size - (NCOLORS + 1))
IF N_Elements(currentColorIndex) EQ 0 THEN currentColorIndex = (startIndex + NCOLORS - 1)
currentColorIndex = currentColorIndex < 255
IF Keyword_Set(name) THEN needSliders = 0 ELSE needSliders = 1

   ; Get the current color tables so they can be restored on exit.

TVLCT, r_old, g_old, b_old, /Get

   ; Load the new drawing colors and get their names.

names =  ['Black', 'Magenta', 'Cyan', 'Yellow', 'Green']
red =    [  0,        255,       0,      255,       0  ]
green =  [  0,          0,     255,      255,     255  ]
blue =   [  0,        255,     255,        0,       0  ]
names =  [names,  'Red', 'Blue', 'Navy', 'Pink', 'Aqua']
red =    [red,     255,     0,      0,    255,    112]
green =  [green,     0,     0,      0,    127,    219]
blue =   [blue,      0,   255,    115,    127,    147]
names =  [names,  'Orchid', 'Sky', 'Beige', 'Charcoal', 'Gray', 'White']
red =    [red,      219,      0,     255,       80,      135,     255  ]
green =  [green,    112,    163,     171,       80,      135,     255  ]
blue =   [blue,     219,    255,     127,       80,      135,     255  ]
colorNames = names
nameIndex = currentColorIndex - startIndex
IF nameIndex GE 0 AND nameIndex LE N_Elements(colorNames) THEN BEGIN
   currentName = colorNames[nameIndex]
ENDIF ELSE currentName = ""
TVLCT, red, green, blue, startIndex
TVLCT, r, g, b, /Get
IF Keyword_Set(name) THEN labelTitle = currentName ELSE labelTitle = 'Current Color'

   ; Create the widgets. TLB is MODAL or BLOCKING.

IF N_Elements(groupLeader) EQ 0 THEN BEGIN
   tlb = Widget_Base(Title=title, Column=1, /Base_Align_Center)
ENDIF ELSE BEGIN
   tlb = Widget_Base(Title=title, Column=1, /Base_Align_Center, /Modal, $
      Group_Leader=groupLeader)
ENDELSE

colorbaseID = Widget_Base(tlb, Row=2, Event_Pro='PickColor_Select_Color')
drawID = LonArr(16)
FOR j=0,NCOLORS-1 DO BEGIN
   drawID[j] = Widget_Draw(colorbaseID, XSize=20, YSize=15, $
      UValue=colorNames[j], Button_Events=1)
ENDFOR
currentID = Widget_Base(tlb, Column=1, Base_Align_Center=1)
labelID = Widget_Label(currentID, Value=labelTitle, /Dynamic_Resize)
currentColorID = Widget_Draw(currentID, XSize=60, YSize=15)

IF needSliders THEN BEGIN

   sliderbase = Widget_Base(tlb, COLUMN=1, FRAME=1, BASE_ALIGN_CENTER=1, $
      EVENT_PRO='PickColor_Sliders')
   label = Widget_Label(sliderbase, Value='Specify a Color')

      ; Set the current color values in sliders.

   redID = Widget_Slider(sliderbase, Scr_XSize=200, Value=r[currentColorIndex], $
      Max=255, Min=0, Title='Red')
   greenID = Widget_Slider(sliderbase, Scr_XSize=200, Value=g[currentColorIndex], $
      Max=255, Min=0, Title='Green')
   blueID = Widget_Slider(sliderbase, Scr_XSize=200, Value=b[currentColorIndex], $
      Max=255, Min=0, Title='Blue')

ENDIF ELSE BEGIN

   redID = 0L
   greenID = 0L
   blueID = 0L

ENDELSE

buttonbase = Widget_Base(tlb, ROW=1, Align_Center=1, Event_Pro='PickColor_Buttons')
cancelID = Widget_Button(buttonbase, VALUE='Cancel')
acceptID = Widget_Button(buttonbase, VALUE='Accept')

   ; Center the TLB.

PickColor_CenterTLB, tlb
Widget_Control, tlb, /Realize

   ; Load the drawing colors.

wids = IntArr(NCOLORS)
FOR j=0, NCOLORS-1 DO BEGIN
   Widget_Control, drawID[j], Get_Value=thisWID
   wids[j] = thisWID
   WSet, thisWID
   PolyFill, [0,0,1,1,0], [0,1,1,0,0], /Normal, Color=startIndex + j
ENDFOR

   ; Load the current color.

Widget_Control, currentColorID, Get_Value=currentWID
WSet, currentWID
TVLCT, r[currentColorIndex], g[currentColorIndex], b[currentColorIndex], currentColorIndex
PolyFill, [0,0,1,1,0], [0,1,1,0,0], /Normal, Color=currentColorIndex

   ; Pointer to hold the form information.

ptr = Ptr_New({cancel:1.0, r:r_old[currentColorIndex], g:g_old[currentColorIndex], $
         b:b_old[currentColorIndex], name:currentName})

   ; Info structure for program information.

info = { ptr:ptr, $                    ; The pointer to the form information.
         r_old:r_old, $                ; The old color table.
         g_old:g_old, $
         b_old:b_old, $
         r:r, $                        ; The new color table.
         g:g, $
         b:b, $
         labelID:labelID, $
         needSliders:needSliders, $    ; A flag that indicates if sliders are needed.
         redID:redID, $                ; The IDs of the color sliders.
         greenID:greenID, $
         blueID:blueID, $
         currentName:currentName, $    ; The current color name.
         currentColorIndex:currentColorIndex, $  ; The current color index.
         currentWID:currentWID, $      ; The current color window index number.
         wids:wids $                   ; The window index number of the drawing colors.
       }

Widget_Control, tlb, Set_UValue=info, /No_Copy
XManager, 'pickcolor', tlb ; Block here until widget program is destroyed.

   ; Retrieve the color information.

colorInfo = *ptr
Ptr_Free, ptr
cancelled = colorInfo.cancel

   ; Restore decomposed state if possible.

IF Float(!Version.Release) GE 5.2 THEN Device, Decomposed=decomposedState

   ; Return the color triple.

IF Keyword_Set(name) THEN RETURN, colorInfo.name ELSE $
   RETURN, Reform([colorInfo.r, colorInfo.g, colorInfo.b], 1, 3)
END
