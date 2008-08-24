;
    pro int, a
    a= .25*(a+shift(a,1,0)+shift(a,1,1)+shift(a,0,1) )
    a=reform(a(1:*,1:*))
    return
    end
