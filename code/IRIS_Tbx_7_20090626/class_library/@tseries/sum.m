function x = sum(x,dim)
%
% <a href="tseries/sum">SUM</a>  Sum of time series elements.
%
% Syntax:
%   x = cumsum(x)
%   x = cumsum(x,dim)
% Output arguments:
%   x [ tseries | numeric ] Numeric array or time series with cumulated elements.
% Required input arguments:
%   x [ tseries ] Times series whose elements to sum.
% Required input arguments for syntax #2:
%   dim [ numeric ] Sumation works along dimension dim.
%
% The IRIS Toolbox 2007/07/25. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  dim = 1;
end

%% function body --------------------------------------------------------------------------------------------

x = unop_(@sum,x,dim,dim);

end

% end of primary function -----------------------------------------------------------------------------------