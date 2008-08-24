; reads an output from Filippo's deltaf program
; create df(nx,ny) ix(nx) iy(ny) for contour etc.
; .r
iunit=7
file=' '
read,'File = ',file
openr,iunit,file
readf,iunit,nx,ny
readf,iunit,xmin,xmax,ymin,ymax
df=fltarr(nx,ny)
readf,iunit,df
ix=findgen(nx)/(nx-1)*(xmax-xmin)+xmin
iy=findgen(ny)/(ny-1)*(ymax-ymin)+ymin
close,iunit
print, min(df), max(df)
end
