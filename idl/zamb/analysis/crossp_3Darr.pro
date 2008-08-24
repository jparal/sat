function crossp_3Darr, v1, v2
   on_error,2                      ;Return to caller if an error occurs
   
   v3 = v1
   
   v3[0,*,*] = v1[1,*,*]*v2[2,*,*]-v2[1,*,*]*v1[2,*,*]
   v3[1,*,*] = v1[2,*,*]*v2[0,*,*]-v2[2,*,*]*v1[0,*,*]
   v3[2,*,*] = v1[0,*,*]*v2[1,*,*]-v2[0,*,*]*v1[1,*,*]
   
   return, v3
end