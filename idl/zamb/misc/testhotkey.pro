

PRO TestHotKey_Event, event

; The event handler for the program.

Widget_Control, event.top, Get_UValue=infoq
thisEvent = Tag_Names(event, /Structure_Name)

   ; Handle character input events. Al other events pass through.

CASE thisEvent OF

   'WIDGET_TEXT_CH': BEGIN

      TVLCT, [0,255], [0,255], [0,0], 1
      Erase, Color=1

         ; Print the character in the window.

      text = 'Character: ('+ StrTrim(event.ch,2) + ')'
      XYOUTS, 0.5, 0.5, /Normal, Alignment=0.5, $
         Color=2, text, Charsize=2.0

         ; Is this a quit character? If so, destroy the widget.

      quitString = 'qQxX'
      index = Where(Byte(quitString) EQ event.ch, count)
      IF count NE 0 THEN Widget_Control, event.top, /Destroy

      ENDCASE

   ELSE: BEGIN

         ; Set the input focus to the text widget. (Mostly
         ; draw widget motion events handled here.)

      Widget_Control, info.hiddenTextID, /INPUT_FOCUS

      ENDCASE

ENDCASE

END ;---------------------------------------------------------------------------



PRO TestHotKey

   ; Color decomposition off.

Device, Decomposed=0

   ; Create the program's widgets. The text widget is hidden behind
   ; the draw widget in the bullitin board top-level base. Motion
   ; events turned on for the draw widget to get into the event handler
   ; and put input focus on the text widget.

tlb = Widget_Base(Column=1, Title='Select Key from Keyboard. "Q" or "X" to Quit...', $
   XOffset=100, YOffset=200)
;label = Widget_Label(tlb, Value='Hot Key Test')
base = Widget_Base(tlb) ; Bullitin Board Base.
drawID = Widget_Draw(base, XSize=500, YSize=200, /Motion_Events)

   ; Text widgets returns all events, but is NOT editable by the user.

hiddenTextID = Widget_Text(base, Scr_XSize=1, Scr_YSize=1, /All_Events)

   ; Realise the hierarchy. Get the window ID of the draw widget.

Widget_Control, tlb, /Realize
Widget_Control, drawID, Get_Value=wid
WSet, wid

   ; Display graphics.

TVLCT, [0,255], [0,255], [0,0], 1
XYOUTS, 0.5, 0.5, /Normal, Alignment=0.5, Charsize=2.0, $
   Color=2, 'Place cursor in window. Select a key.'

   ; Store program information in UValue of TLB.

info = {hiddenTextID:hiddenTextID, wid:wid}
Widget_Control, tlb, Set_UValue=info

XManager, 'testhotkey', tlb, /No_Block
END
