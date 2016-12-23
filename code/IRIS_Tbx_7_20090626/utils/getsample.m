function [sample,flag] = getsample(y)
% True for observations from first non-NaN to last non-NaN, check for within-sample NaNs.

% The IRIS Toolbox 2008/09/25.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! Function body.

sample = all(all(~isnan(y),3),1);
first = find(sample,1);
last = find(sample,1,'last');
sample(1:first-1) = false;
sample(last+1:end) = false;
flag = all(sample(first:last));
sample(first:last) = true;

end
% End of primary function.