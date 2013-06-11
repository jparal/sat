function haxes = sat_subplot(Nv, Nh, gap, marg_h, marg_w)

% sat_subplot creates "subplot" axes with adjustable gaps and margins
% The routine is based on "tight_subplot" following differences:
%   * Instead of number of plots "Nv" and "Nh" you specify and array with
%   the ratios of the size of the axis in horizontal and vertical direction
%
% haxes = sat_subplot(Nv, Nh, gap, marg_h, marg_w)
%
%   in:  Nv      number of axes in hight (vertical direction)
%                or an array of the ratios of the vertical axis sizes
%        Nh      number of axes in width (horizontal direction)
%                or an array of the ratios of the horizontal axis sizes
%        gap     gaps between the axes in normalized units (0...1)
%                   or [gap_h gap_w] for different gaps in height and width 
%        marg_h  margins in height in normalized units (0...1)
%                   or [lower upper] for different lower and upper margins 
%        marg_w  margins in width in normalized units (0...1)
%                   or [left right] for different left and right margins 
%
%  out:  ha     array of handles of the axes objects
%                   starting from upper left corner, going row-wise as in
%                   going row-wise as in
%
%  Example: ha = tight_subplot(3,2,[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')
%
%  Example: ha = tight_subplot([2 1 1],[1 1],[.01 .03],[.1 .01],[.01 .01])
%           for ii = 1:6; axes(ha(ii)); plot(randn(10,ii)); end
%           set(ha(1:4),'XTickLabel',''); set(ha,'YTickLabel','')

% Pekka Kumpulainen 20.6.2010   @tut.fi
% Tampere University of Technology / Automation Science and Engineering


if nargin<3; gap = .02; end
if nargin<4 || isempty(marg_h); marg_h = .05; end
if nargin<5; marg_w = .05; end

if isscalar(Nv) == 1
    Nv = ones(1,Nv);
end
if isscalar(Nh) == 1
    Nh = ones(1,Nh);
end
if numel(gap)==1; 
    gap = [gap gap];
end
if numel(marg_w)==1; 
    marg_w = [marg_w marg_w];
end
if numel(marg_h)==1; 
    marg_h = [marg_h marg_h];
end

axv = (1-sum(marg_h)-(length(Nv)-1)*gap(1))/sum(Nv); 
axh = (1-sum(marg_w)-(length(Nh)-1)*gap(2))/sum(Nh);

haxes = zeros(length(Nv)*length(Nh),1);
ii = 0;
for iv = 1:length(Nv)
    px = marg_w(1);
    py = 1-marg_h(2) - sum(Nv(1:iv))*axv - (iv-1)*gap(1);

    for ih = 1:length(Nh)
        ii = ii+1;
        haxes(ii) = axes('Units','normalized', ...
            'Position',[px py axh*Nh(ih) axv*Nv(iv)], ...
            'XTickLabel','', ...
            'YTickLabel','');
        px = marg_w(1) + sum(Nh(1:ih))*axh + ih*gap(2);
    end
end
