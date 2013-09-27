;DATE:May 2004
;AUTHOR: Dr. Tapuosi Loto'aniu
;PURPOSE:	Extracts Canopus Mag data from ascii files
;			retrieved from Canopus portal
;			http://kate.nic.ualberta.ca/portal
;
;
;DEPENDENCIES: Non
;
;
;
;INPUTS:
;		fname - the data filename, if subroutine is not in same
;		directory as data file then filename must include
;		full path.
;
;OPTIONAL INPUTS: word_month-	set to return date with
;				month in words.
;				Calls - data_expand
;				expand-		set to return data expanded
;						to 24 hours worth with extra
;						data set to default missing value.
;						Calls - data_date
;
;OUTPUT:	Anonymuous structure 'result'
;			result.StaL	- holds station name string
;			result.Year	- Year integer in form 'I4'
;			result.Month	- Month integer in form 'I2'
;			result.Day		- Day integer in form 'I2'
;			result.XDate	- date in form dd/mm/yyyy or
;							e.g. 'January 01 2004'
;			result.Coord	- data coordinate system (e.g.
;							'geodetic') string.
;			result.Unts	- Data units (e.g. 'nT') string.
;			result.SInt	- Data sampling rate Long Integer.
;			result.Points	- Number points Long integer.
;			result.FName	- input filename string.
;			result.DataFile- 3-D double array containing XYZ mag
;					data (e.g. result.DataFile(0) for X
;					component).
;			result.TimFile	- Time values Long integer.
;			result.checkind- structure containing index positions of
;					missing and suspicious data values. E.g.
;					result.checkind.(0) contains index position
;					of missing data in result.DataFile(0,*).
;					The last array result.checkind.(3) contains
;					the suspect index positions.
;
;CALLING:		 	If you are not familiar with structures in IDL or C
;					read on. The structure 'result' is only used to return
;					the anonymuous structure. If I call the function in the main
;					program e.g. CanopusData=canopus_input(fname),
;					remember the structure is accessible through
;					'CanopusData' not 'result'. The structure 'result' ceases
;					to exist once the function call is over but the structure variables
;					are passed to the new structure 'CanopusData' along with their names.
;					In the "OUTPUT"	section above you would replace 'result' with 'CanopusData'
;					or whatever other structure name you decide to use in the main program.
;
;Modification History:
;Dr. Tapuosi Loto'aniu - 04/0902004: Changed checkind array to
;                        structure.
;
function canopus_input_dkm,fname,word_month=word_month,expand=expand,exitcode=exitcode
    ;
	;
	;Open datafile
	;
	Get_Lun,u
	OpenR,u,FName

	;Initialize variables
	;
	text=''
	text0=''
	chck=''
	X=0.0
	Y=0.0
	Z=0.0
	StaL=''
	Coord=''
	Unts=''
	Hour=''
	Min=''
	Sec=''
	;
	;
	;Loop pass header info
	;
	for i=0,38 do $
	readf,u,text
	;
	;Read in first data line of file
	;
	ReadF,u,Format='(A4,1x,2F8.3,I4,2I2,A10,A2,I6)',$
	StaL,Lat,Lon,Year,Month,Day,$
	Coord,Unts,Points

	;Initialize variables given the number of Points
	;
	DataFile=DblArr(3,Points)
	DtaFile0=DblArr(Points)
	DtaFile1=DblArr(Points)
	DtaFile2=DblArr(Points)
	TimFile=lonarr(Points)
	check=strarr(Points)
	;

	;***********************************************************
	;Start input loop for data values
	;
	for i=0,Points-1 do $
		begin
		ReadF,u,text0,X,Y,Z,chck,FORMAT='(A14,F10.3,F10.3,F10.3,A2)'
	;
	;
	;Determine sampling rate.
	;
		if i EQ 0 then $
			t0_temp=long(strtrim(strmid(text0,12,2),1))
		if i EQ 1 then $
			SInt = long(long(strtrim(strmid(text0,12,2),1)) - t0_temp)
	;
	;Determine time
	;
		Hour=strtrim(strmid(text0,8,2),1)
		XMin=strtrim(strmid(text0,10,2),1)
		Sec=strtrim(strmid(text0,12,2),1)
	;
	;Pass values to respective permanent data holders
	;
	;
		TimFile[i]=Long(Long(Hour)*60.*60.+Long(Xmin)*60.+long(Sec))
		DtaFile0[i] = X
		DtaFile1[i] = Y
		DtaFile2[i] = Z
		check[i]=chck
	end
	;End of for loop for data input
	;
	;************************************************************
	;
	;Close file
	;
	Free_Lun,u
	;
	;-------------------------------------------------
	;Check data for error tags
	;
	index0=where(Dtafile0 EQ 99999.992,count0)
	index1=where(Dtafile1 EQ 99999.992,count1)
	index2=where(Dtafile2 EQ 99999.992,count2)
	index3=where(strtrim(check,1) NE '.',count3)
	;
	;Structure containing index position of error and
	;suspicious data.
	;
	checkind={index0:index0,index1:index1,index2:index2,index3:index3}
	;
	;-------------------------------------------------
	;Pass Magnetic data values to 3-D array
	;
	DataFile=DblArr(3,Points)
	Datafile[0,*]=Dtafile0
	Datafile[1,*]=Dtafile1
	Datafile[2,*]=Dtafile2
	;
	;-----------------------------------------------------
	;If set checks that data cover entire day. If not
	;it returns expanded time data length to 24 hours and sets
	;extra magnetometer data values to default missing
	;value which for CANOPUS is 99999.992 - else if not set
	;original data lenght is preserved.

	IF KEYWORD_SET(expand) THEN $
		BEGIN
		Xstatn1=data_expand(Timfile,Datafile,Points,99999.992)
	end else $
		Xstatn1={old_time:TimFile,XnDatafile:Datafile}
	;----------------------------------------------------

	;-------------------------------------------------------
	;If set returns Xdate in format "month in words+day+year"
	;else if not set Xdate given in format "day/month/year"
	;
	IF KEYWORD_SET(word_month) THEN $
		BEGIN
		XDate=data_date(Year,month,day)
	end else $
		XDate=strtrim(long(day),1)+'/'+strtrim(long(month),1)+'/'+strtrim(long(year),1)
	;
	;--------------------------------------------------------
	;
	;*****************************************************************
	;Pass values to anonymuous structure. See header for explaination
	;
;	result={StaL:StaL,Year:Year,Month:Month,Day:Day,Date:XDate,$
;		    Coord:Coord,Unts:Unts,SInt:SInt,Points:n_elements(Xstatn1.(0)),$
;		    FName:FName,DataFile:Xstatn1.(1),TimFile:Xstatn1.(0),checkind:checkind}
	;*****************************************************************
	


        data_params={datafile_parameters, $
        titlestring: StaL,$
        st_name:StaL,min:0,sec:0,$
        hour:0,dayno:0,day:day,month:month,year:year,nmins:1440,$
        npoints:n_elements(Xstatn1.(0)),samp_int:Sint}

	data_vals={data_values, h:Datafile[0,*],d:Datafile[1,*],z:Datafile[2,*]}
	exitcode=0
	result={filename:FName,data_params:data_params,data_vals:data_vals}
	
	;------------------------------------------------------------
	;returning as much memory as possible to heap.
	;
	Xstatn1=0
	index0=0
	index1=0
	index2=0
	index3=0
	DataFile=0
	checkind=0
	check=0
	;
	;******************************************************
	;
	return,result
end
