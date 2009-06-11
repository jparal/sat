function [dout] = dat_despike(din,nsigma,npoints)
%
%  function [dout] = DAT_DESPIKE (din,nsigma,npoints)
%  despike input data
%
%  dout .... output despiked data
%  din ..... input data [1D array]
%  nsigma .. number of standart deviations considered as a spike
%  npoint .. number of points used in each direction used for computing std
%            deviation (i.e. total number is 2*npoints+1)
%
%  HISTORY:
%  SAT v1.1.1, 2009/06 (Jan Paral: jparal@gmail.com)
%    Initial version

if nargin < 3
  npoints = 10;
end
if nargin < 2
  nsigma = 1;
end

dout = din; 

% replace the bad values in dout with means
for j = (1+npoints):length(din)-npoints
  rb = j - npoints; ra = j + npoints;   
  if abs(din(j) - nanmean(din(rb:ra))) > nsigma*nanstd(din(rb:ra))
    dout(j) = nanmean(din(rb:ra));
  end % if
end % for
