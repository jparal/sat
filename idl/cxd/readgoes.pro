Function readgoes,datafile,lnum
 openr,lun1, datafile,/get_lun

text = ''

for i = 0, lnum do begin
readf, lun1, text
endfor
 print, text

; 12-02-2001 00:00:30.000               -12.2122               -54.5998                80.9065               -8129.02                40990.1                5599.05


line = fltarr(12)
while not eof(lun1) do begin
; 12-02-2001 00:00:30.000               -12.2122               -54.5998                80.9065               -8129.02                40990.1                5599.05
readf, lun1, line, format='(I2,x,I2,x,I4,x,I2,x,I2,x,f6.3,3f14.4, 3f14)';(I2,x,I2,x,I4,x,I2,x,I2,x,f6.3,3f23.4, 3f23)';

; readf,lun1,line,format='(I2,x,I2,x,I4,x,I2,x,I2,x,f6.3,6f23)';3f23.4,3f23)' 
	if(n_elements(data) eq 0) then begin
	data = line
	endif else begin
	data = [[data],[line]]
	endelse
endwhile


for i = 0, n_elements(data)-1 do begin
 if data[i] le -1.00000E+31 then begin
 data[i] = !Values.D_NAN;data[i-1]
 endif 
endfor



close,lun1
free_lun,lun1

datastruct={$
	col0:reform(data(0,*),n_elements(data(0,*))), $ ;day
	col1:reform(data(1,*),n_elements(data(1,*))), $ ; month
	col2:reform(data(2,*),n_elements(data(2,*))), $ ; year
	col3:reform(data(3,*),n_elements(data(3,*))), $ ; hour
	col4:reform(data(4,*),n_elements(data(4,*))), $ ; min
	col5:reform(data(5,*),n_elements(data(5,*))), $ ; second
	col6:reform(data(6,*),n_elements(data(6,*))), $ ; bx_gsm
	col7:reform(data(7,*),n_elements(data(7,*))), $ ; by_gsm
	col8:reform(data(8,*),n_elements(data(8,*))), $ ; bz_gsm
	col9:reform(data(9,*),n_elements(data(9,*))), $ ; px_gsm
	col10:reform(data(10,*),n_elements(data(10,*))), $ ; py_gsm
	col11:reform(data(11,*),n_elements(data(11,*)))  $ ; pz_gsm
	}	

return, datastruct

; io_err:	free_lun, in_unit;
; 	print,"Error reading file";
; 	return,0
end