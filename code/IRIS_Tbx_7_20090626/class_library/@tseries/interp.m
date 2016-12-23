function x = interp(x,range,varargin)
% INTERP  Interpolate NaN observations.

% The IRIS Toolbox 2009/06/04.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {
   'method','cubic',@ischar,...
};
options = passvalopt(default,varargin{:});

if nargin < 2
   range = Inf;
end

%********************************************************************
%! Function body.

if any(isinf(range))
   range = get(x,'range');
elseif ~isempty(range)
   range = range(1) : range(end);
   x.data = rangedata(x,range);
   x.start = range(1);
else
   x = empty(x);
   return
end

data = x.data(:,:);
grid = dat2grid(range);
grid = grid - grid(1);
for i = 1 : size(data,2)
   index = ~isnan(data(:,i));
   if any(~index)
      data(~index,i) = interp1(...
         grid(index),data(index,i),grid(~index),options.method,'extrap');   
   end
end
x.data(:,:) = data;

end
% End of primary function.