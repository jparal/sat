
imzeta=hdf5read('output.h5','imzeta');
rezeta=hdf5read('output.h5','rezeta');
repfnc=hdf5read('output.h5','repfnc');
impfnc=hdf5read('output.h5','impfnc');

zeta = [rezeta]+[imzeta]*i;

pfnc=i*sqrt(pi)*exp(-zeta.^2)-2*zeta.*(1-(2/3)*zeta.^2+(4/15)*zeta.^4);
pfnc=i*sqrt(pi)*faddeeva(zeta);

subplot 211
plot(rezeta,repfnc-real(pfnc))
subplot 212
plot(rezeta,impfnc-imag(pfnc))