Function MinN0, Data, MAX = localmax, MINN0 = localmin_non0
   LocalMin = Min(Data, MAX = LocalMax)
   if ((LocalMin le 0.0) and (LocalMax gt 0.0)) then begin    
       idx = Where(Data gt 0.0)
       LocalMin_Non0 = Min(Data[temporary(idx)])        
   end else LocalMin_Non0 = LocalMin          
   return, LocalMin 
end

