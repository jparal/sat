function sat_fix_ylabels(ha)
% This function align ylables in X-direction. The function is useful after
% using sat_subplot().
% 
% Example:
%  ha = sat_subplot(...);
%  sat_fix_ylables(ha);

hlabels=cell2mat(get(ha,'YLabel'));
plabels=cell2mat(get(hlabels,'Position'));
plabels(:,1) = min(plabels(:,1));
for i=1:length(ha)
    set(hlabels(i),'Position',plabels(i,:));
end
