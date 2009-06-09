function [dout] = dat_despike(din,limit,range)

if nargin < 3
  range = 10;
end
if nargin < 2
  limit = 1;
end

dout = din; 

% replace the bad values in dout with means
for j = (1+range):length(din)-range
  rb = j - range; ra = j + range;   
  if abs(din(j) - nanmean(din(rb:ra))) > limit*nanstd(din(rb:ra))
    dout(j) = nanmean(din(rb:ra));
  end % if
end % for
