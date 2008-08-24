;
  pro m1_event, event
  common coor, x,y,z,t
  common list, list0,list1,list2,list3
  type=tag_names(event,/structure)
  print, type
  if (type eq 'WIDGET_TEXT') then begin
   widget_control, get_value=i , event.id
   j= event.top
   help, i
   ii=i(0)
   help, ii
   print, i,j
  endif
  if (type eq 'WIDGET_BUTTON') then widget_control, event.top,/destroy
  if (type eq 'WIDGET_LIST') then begin
    j= event.id
    i= event.index
    print, j,list0,i
    if (j eq list0) then x=i
    if (j eq list1) then y=i
    if (j eq list2) then z=i
    if (j eq list3) then t=i
   endif
  print, x,y,z,t
end
