; hdf_test

iter = 10
time = 0.520

NX = 100
MinX = -1.0
MaxX =  2.0

NY = 150
MinY = -2.0
MaxY =  1.0

data = DblArr(NX,NY)

XAxis = FIndGen(NX)*(MaxX-MinX)/(NX-1) + MinX
YAxis = FIndGen(NY)*(MaxY-MinY)/(NY-1) + MinY


for i=0,NX-1 do begin
  for j=0,NY-1 do begin
    data[i,j] = exp(-(XAxis[i]^2+YAxis[j]^2)/0.5^2)
  end
end

Plot2D, Data, XAxis = XAxis, YAxis = YAxis

;-------------------------------------------- Write HDF File -----------------------------


filename = Dialog_PickFile(/write)

; Create HDF_SD file

sdfileID = HDF_SD_Start(filename, /create)

; Add Data

sdsID = HDF_SD_Create(sdFileID, 'Data0', [NX,NY], /DFNT_FLOAT64)

HDF_SD_AddData, sdsID, data

; Add User defined Attributes to the sds

HDF_SD_AttrSet, sdsID, 'ITERACTION', iter

HDF_SD_AttrSet, sdsID, 'SIMULATION TIME', time

; Add predefined attributes to the sds

HDF_SD_SetInfo, sdsID, UNIT = '1/(e*(c/wp)^2)', LABEL = 'Charge density' 

; Add axis information

dim0ID = HDF_SD_DimGetID(sdsID, 0)
dim1ID = HDF_SD_DimGetID(sdsID, 1)

HDF_SD_DimSet, dim0ID, $
               Label = 'x1', $
               Name = 'x1 axis', $
               Scale = XAxis, $
               Unit = 'c/wp' 
 
HDF_SD_DimSet, dim1ID, $
               Label = 'x2', $
               Name = 'x2 axis', $
               Scale = YAxis, $
               Unit = 'c/wp' 

; Close the file

HDF_SD_End, sdfileID

end