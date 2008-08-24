PRO Example_Cleanup, tlb

   ; Cleanup routine when TLB widget dies. Be sure
   ; to destroy Show Progress objects.

Widget_Control, tlb, Get_UValue=info
Obj_Destroy, info[0]
Obj_Destroy, info[1]
END


PRO Example
Device, Decomposed=0
TVLCT, 255, 0, 0, 20
tlb = Widget_Base(Column=1, Xoffset=200, Yoffset=200)

   ; Create an AutoUpDate object. Store in UValue of Button.

autoTimer = Obj_New("ShowProgress", tlb, Color=20, Steps=20, Delay=5, /AutoUpdate)
button = Widget_Button(tlb, Value='Automatic Mode', UValue=autoTimer)

   ; Create a Manual Show Progress object. Store in UValue of Button.

progressTimer = Obj_New("ShowProgress", tlb, Color=20, /CancelButton)
button = Widget_Button(tlb, Value='Manual Mode', UValue=progressTimer)

quiter = Widget_Button(tlb, Value='Quit', UValue='QUIT')

Widget_Control, tlb, /Realize, Set_UValue=[autoTimer, progressTimer]
XManager, 'example', tlb, /No_Block, Cleanup='example_cleanup'
END