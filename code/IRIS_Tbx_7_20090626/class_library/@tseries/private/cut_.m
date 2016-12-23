function x = cut_(x)
% CUT_  Remove leading and trailing NaNs.

% The IRIS Toolbox 2008/12/17.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================

%! Function body.

% Return immediately if empty or at least one number in first and last period.
if isempty(x.data) || (any(~isnan(x.data(1,:))) && any(~isnan(x.data(end,:))))
   return
end

dim = size(x.data);
remove = isnan(x.data);
remove = all(remove(:,:),2);
if any(~remove) && any(remove)
   from = find(~remove,1);
   to = find(~remove,1,'last');
   x.start = x.start + from - 1;
   index = from : to;
   x.data = x.data(index,:);
   x.data = reshape(x.data,[length(index),dim(2:end)]);
elseif all(remove)
   x.start = NaN;
   x.data = zeros([0,dim(2:end)]);
   index = [];  
end

end
% End of primary function.