function [dout] = dat_filter(din,flo,fhi,dt)
%
%  function [dout] = DAT_FILTER (din,flo,fhi,dt)
%  filter out frequencies between flo and fhi using Keiser filter
%  (i.e. using Bessel functions
%
%  dout .. output data [1D array]
%  din ... data input [1D array]
%  flo ... lower frequency [Hz]
%  fhi ... higher frequency [Hz]
%  dt .... data resolution [seconds]
%
%  EXAMPLES:
%  High pass filter:      d = psd_filter(data, 1, 0, 60);
%  Low pass filter:       d = psd_filter(data, 0, 1, 60);
%  Band filter (1-2 Hz):  d = psd_filter(data, 1, 2, 60);
%
%  HISTORY:
%  SAT v1.1.1, 2009/06 (Jan Paral: jparal@gmail.com)
%    Initial version

gibbs=76.8345;
fnyquist=1./(2*dt);

if (flo > 0)
    tlo = 1/flo;
else
    tlo = 0;
end
if (fhi > 0)
    thi = 1/fhi;
else
    thi = 0;
end

nterms= max([1, (3*fnyquist*max([tlo, thi]))]);

if (thi > 2*dt)
    fhi=1/(fnyquist*thi);
else
    fhi=1;
end
if (tlo > 2*dt)
    flo=1/(fnyquist*tlo);
else
    flo=0;
end


if (fhi < flo)
    fstop = 1;
else
    fstop = 0;
end

if (gibbs <= 21.)
    alpha = 0;
elseif (gibbs >= 50.)
    alpha = 0.1102 *(gibbs-8.7);
else
    alpha = 0.5842*(gibbs-21)^0.4 + 0.07886*(gibbs-21);
end

arg = (1:nterms)/nterms;
coef = besseli(0,alpha*sqrt(1-arg.^2))/besseli(0,alpha);
T = (1:nterms)*pi;
coef = coef .* (sin(T*fhi)-sin(T*flo))./T;
coef = [coef(end:-1:1), fhi - flo + fstop, coef];

dout = conv(din,coef,'same');
