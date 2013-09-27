pro read_bin, filename

print, 'Parsing datafile'
a=read_sam(filename)

print, 'Titlestring: ',a.data_params.titlestring
print, 'Station Name:',a.data_params.st_name
print, 'Start Hour:  ',a.data_params.hour
print, 'Start Minute:',a.data_params.min
print, 'Start Second:',a.data_params.sec
print, 'Day Number:  ',a.data_params.dayno
print, 'Day of Month:',a.data_params.day
print, 'Month:       ',a.data_params.month
print, 'Year:        ',a.data_params.year
print, 'No. Minutes: ',a.data_params.nmins
print, 'Data Points: ',a.data_params.npoints
print, 'Sample Int:  ',a.data_params.samp_int

end
