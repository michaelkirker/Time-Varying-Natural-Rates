function x = resize(x,range)
% RESIZE  Change time series range.
%
% Syntax:
%   x = resize(x,range)
% Required input arguments:
%   x tseries; range numeric

% The IRIS Toolbox 2009/06/10.
% Copyright 2007-2009 Jaromir Benes.

if ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

if isempty(range) || isnan(x.start)
   x = empty(x);
   return
elseif all(isinf(range))
   return
end

if isinf(range(1))
   startdate = x.start;
else
   startdate = range(1);
end

if isinf(range(end))
   enddate = x.start + size(x.data,1) - 1;
else
   enddate = range(end);
end

tmpsize = size(x.data);
newrange = startdate : enddate;
index = round(newrange - x.start + 1);
newrange(index < 1) = [];
newrange(index > tmpsize(1)) = [];
index(index < 1) = [];
index(index > tmpsize(1)) = [];
if ~isempty(index)
   x.data = x.data(:,:);
   x.data = x.data(index,:);
   x.data = reshape(x.data,[length(index),tmpsize(2:end)]);
   x.start = newrange(1);
else
   x.data = zeros([0,tmpsize(2:end)]);
   x.start = NaN;
end

end
% End of primary function.