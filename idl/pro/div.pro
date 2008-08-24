; calculate a divergence di of ax, ay, az
; with specified dx, dy, dz
    pro div,dx,dy,dz, ax,ay,az, di
    dxi=1./dx
    dyi=1./dy
    dzi=1./dz
    di=dxi*.25*(shift(ax,1,0,0)-ax + $
            shift(ax,1,1,0)-shift(ax,0,1,0) + $
            shift(ax,1,1,1)-shift(ax,0,1,1) + $
            shift(ax,1,0,1)-shift(ax,0,0,1) )
    di=di+dyi*.25*(shift(ay,0,1,0)-ay + $
            shift(ay,1,1,0)-shift(ay,1,0,0) + $
            shift(ay,1,1,1)-shift(ay,1,0,1) + $
            shift(ay,0,1,1)-shift(ay,0,0,1) )
    di=di+dzi*.25*(shift(az,0,0,1)-az + $
            shift(az,1,0,1)-shift(az,1,0,0) + $
            shift(az,1,1,1)-shift(az,1,1,0) + $
            shift(az,0,1,1)-shift(az,0,1,0) )
    return
   end
  
