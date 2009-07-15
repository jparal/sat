pro rdexpin,filename=filename,lxd=lxd,lyd=lyd,lzd=lzd
lxd=0.
lyd=0.
lzd=0.
comments='                                     '
if(fexist(filename))then begin
  iue=21
  openr,iue,filename
  readf,iue,comments
  readf,iue,lxd,lyd,lzd
  close,iue
endif
return
end
