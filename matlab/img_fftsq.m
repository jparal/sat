% Plot FFT of up to three data
%   [k,w,dat] = img_fftsq(dx,dtout,d1,d2,d3)
%
%   dx .......... spatial resolution in X
%   dtout ....... temporal resolution of data
%   d1[,d2,d3] .. data(time,space)

function [k,w,dat] = img_fftsq(dx,dtout,d1,d2,d3)

dt= dtout;
ss = size(d1);
nt = ss(1);
ns = ss(2);

w=2*pi*[-nt/2+1:nt/2]./(nt*dt);
k=2*pi*[-ns/2+1:ns/2]./(ns*dx);

dat = abs(fft2(d1)).^2;
if nargin >= 4
    dat = dat + abs(fft2(d2)).^2;
end
if nargin >= 5
    dat = dat + abs(fft2(d3)).^2;
end
dat = fftshift(sqrt(dat));

imagesc(k,w,dat)
xlabel('k')
ylabel('\omega');
