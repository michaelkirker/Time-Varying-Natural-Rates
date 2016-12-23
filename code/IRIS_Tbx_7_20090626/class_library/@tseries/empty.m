function x = empty(x)
% <a href="matlab: edit tseries/empty">EMPTY</a>  Empty a time series preserving its class and size in 2nd+ dimensions.
%
% Syntax:
%   x = empty(x)
% Output arguments:
%   x [ tseries ] An empty time series.
% Required input arguments:
%   x [ tseries ] Time series to be emptied.

% The IRIS Toolbox 2009/06/04.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

x.start = NaN;
tmpsize = size(x.data);
x.data = zeros([0,tmpsize(2:end)]);

end
% End of primary function.