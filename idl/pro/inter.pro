;
    pro inter, a
    a= .125*(a+shift(a,0,1,0,0)+shift(a,0,1,1,0)+shift(a,0,1,0,1)+ $
     shift(a,0,1,1,1)+shift(a,0,0,1,0)+shift(a,0,0,1,1)+shift(a,0,0,0,1))
    a=reform(a(*,1:*,1:*,1:*))
    return
    end
