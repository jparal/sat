; home made help;  reads three lines of 
; diskx:[hellinger.idl.pro]routine.pro
pro helph
b='                                      '
a=' '
read,' routine ',a
a= '/home/helinger/pro/'+a+'.pro'
iunit=9
openr,iunit, a
readf,iunit, b
print, b
readf,iunit, b
print, b
readf,iunit, b
print, b
close,iunit
return
end
