;
  pro m1
  common coor, x,y,z,t
  common list, list0,list1,list2,list3
  x=0
  y=0
  z=0
  t=0
   base=widget_base(title='Coordinates',/row)
   base1=widget_base(base,/column)  
   base2=widget_base(base,/column)
   base3=widget_base(base,/column)
   labelx=widget_label(base1,value='    x',/frame)
   list0=widget_list(base1, value=sindgen(43), ysize=14)
   labely=widget_label(base1,value='    y',/frame)
   help, list0
   list1=widget_list(base1, value=sindgen(43), ysize=14)
   labelz=widget_label(base2,value='    z',/frame)
   list2=widget_list(base2, value=sindgen(43), ysize=14)
   labelt=widget_label(base2,value='    t',/frame)
   list3=widget_list(base2, value=sindgen(43), ysize=14)
   a=widget_button(base3, value='Quit')
   bb=widget_label(base3,value='Enter filename for INIT')
   bbb=widget_text(base3,/editable) 
   bbc=widget_text(base3,value='Pourquoi?') 
   widget_control, /realize, base
   xmanager,'m1', base
  end
