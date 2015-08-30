function [y, idx]= extrema(x, opt)
if strcmp(opt,'max')
    idx = intersect(find(diff(x)>0)+1,find(diff(x)<0));
elseif strcmp(opt,'min')
    idx = intersect(find(diff(x)<0)+1,find(diff(x)>0));
else
    error('Wrong option!')
end
y = x(idx);
return