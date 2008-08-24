Function AbsMin, Data, MAX = localabsmax, MINN0 = localabsmin_non0
   LocalAbsMin = Min(Abs(Data), MAX = LocalAbsMax)
   if ((LocalAbsMin eq 0.0) and (LocalAbsMax gt 0.0)) then begin    
       idx = Where(Abs(Data) gt 0.0)
       LocalAbsMin_Non0 = Min((Abs(Data))[temporary(idx)])        
   end else LocalAbsMin_Non0 = LocalAbsMin          
   return, LocalAbsMin 
end

