% Retun A x B components
function [x, y, z] = mth_cross(ax, ay, az, bx, by, bz)
    
    x = ay .* bz - az .* by;
    y = az .* bx - ax .* bz;
    z = ax .* by - ay .* bx;
