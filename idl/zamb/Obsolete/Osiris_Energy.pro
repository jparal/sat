;
;  Program:  
;
;  Osiris_Energy
;
;  Description:
;
;  Makes a movie of the EM energy from the Osiris outputs, plus a total EM energy over time plot
;
;
;


PRO Osiris_Energy, DIRECTORY = DirName, FIELD = FieldType, NOMOVIE = DontMakeMovie


if N_Elements(FieldType) eq 0 then FieldType = 'b'

if N_Elements(DontMakeMovie) eq 0 then DontMakeMovie = 0

if N_Elements(DirName) eq 0 then begin
   DirName = Dialog_PickFile(/Directory)
   if (DirName eq '') then return
end

DirF1 = DirName+FieldType+'1' 
DirF2 = DirName+FieldType+'2' 
DirF3 = DirName+FieldType+'3' 

CD, DirF1
F1Files = FindFile('*.dx', Count = numF1Files)
if (numF1Files le 1) then begin
  res = Dialog_Message(" Insufficient number of '*.dx' files in the folder "+DirF1 , /Error)
  return
end

CD, DirF2
F2Files = FindFile('*.dx', Count = numF2Files)

CD, DirF3
F3Files = FindFile('*.dx', Count = numF3Files)

if (numF2Files ne numF1Files) then begin
  res = Dialog_Message(" Different number of '*.dx' files in the folder "+DirF2 , /Error)
  return
end

if (numF3Files ne numF1Files) then begin
  res = Dialog_Message(" Different number of '*.dx' files in the folder "+DirF3 , /Error)
  return
end

numFiles = numF1Files

CD, DirF1
AnaliseDX, F1Files[0], DATATITLE = DataName, NX = NX, NY = NY, ORIGIN1 = Origin1, $
           ORIGIN2 = Origin2, DELTA11 = Delta11, DELTA12 = Delta12, DELTA21 = Delta21, $
           DELTA22 = Delta22, DATAFILE = tempfilename, TIMEPHYS = temptime

F1Data = FltArr(numFiles,NY,NX)
F2Data = FltArr(numFiles,NY,NX)
F3Data = FltArr(numFiles,NY,NX)

Times = FltArr(numFiles)
sTimes = StrArr(numFiles)

Data0=FltArr(NY,NX) 
Header = FltArr(1)
work_file_id = 1


Print, " Reading Data..."

; Time

Times[0] = temptime
sTimes[0] = "Time = " + String(temptime,Format='(f6.2)') + " [1/Wp]"
print, sTimes[0]

; Field1

Close, work_file_id
OpenR, work_file_id, tempfilename
ReadU, work_file_id, Header
ReadU, work_file_id, Data0
F1Data[0,*,*]=Data0
Close, work_file_id

; Field2

CD, DirF2
AnaliseDX, F2Files[0], DATAFILE=tempfilename
Close, work_file_id
OpenR, work_file_id, tempfilename
ReadU, work_file_id, Header
ReadU, work_file_id, Data0
F2Data[0,*,*]=Data0
Close, work_file_id

; Field3

CD, DirF3
AnaliseDX, F3Files[0], DATAFILE=tempfilename
Close, work_file_id
OpenR, work_file_id, tempfilename
ReadU, work_file_id, Header
ReadU, work_file_id, Data0
F3Data[0,*,*]=Data0
Close, work_file_id


for i=1, numFiles-1  do begin
    
   CD, DirF1 
   AnaliseDX, F1Files[i], DATAFILE=tempfilename, TIMEPHYS = temptime
   
   ; Time
   Times[i] = temptime
   sTimes[i] = "Time = " + String(temptime,Format='(f6.2)') + " [1/Wp]"
   print, sTimes[i]

   ; Field1

   Close, work_file_id
   OpenR, work_file_id, tempfilename
   ReadU, work_file_id, Header
   ReadU, work_file_id, Data0
   F1Data[i,*,*]=Data0
   Close, work_file_id

   ; Field2
    
   CD, DirF2 
   AnaliseDX, F2Files[i], DATAFILE=tempfilename
   Close, work_file_id
   OpenR, work_file_id, tempfilename
   ReadU, work_file_id, Header
   ReadU, work_file_id, Data0
   F2Data[i,*,*]=Data0
   Close, work_file_id

   ; Field3
   
   CD, DirF3
   AnaliseDX, F3Files[i], DATAFILE=tempfilename
   Close, work_file_id
   OpenR, work_file_id, tempfilename
   ReadU, work_file_id, Header
   ReadU, work_file_id, Data0
   F3Data[i,*,*]=Data0
   Close, work_file_id

end

Print, " Calculating Axis Data ..."

XAxisData = FIndGen(NX)*(NX*Delta21)/(NX-1)+Origin1
YAxisData = FIndGen(NY)*(NY*Delta12)/(NY-1)+Origin2

Print, " Calculating |",fieldtype,"|^2"

F1Data = F1Data^2
F2Data = F2Data^2
F3Data = F3Data^2

F1Data = F1Data + F2Data + F3Data

Print, " Generating Total Energy versus Time Plot"
TEner=FltArr(numFiles)
for i=0,numFIles-1 do TEner[i] = Total(F1Data[i,*,*])
Window, Title = DirName, /Free
Plot, Times, TEner, TITLE = "Total "+fieldtype+" field energy over time", $
      XTITLE = "Time [1/Wp]", YTITLE = "Sum |"+fieldtype+"|^2", /YLog


if (DontMakeMovie eq 0) then begin

  Print, " Generating Movie ... "

  MovieColorData, F1Data, XAXIS = XAxisData, YAXIS = YAxisData, PLOTTITLE = "|"+fieldtype+"|^2",$
                  FRAMELABELS = sTimes
end


Print, " Done!"

end