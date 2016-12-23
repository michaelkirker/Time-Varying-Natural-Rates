function x = cumsum(x,dim)
%
% <a href="tseries/cumsum">CUMSUM</a>  Cumulative sum of time series elements.
%
% Syntax:
%   x = cumsum(x)
%   x = cumsum(x,dim)
% Output arguments:
%   x [ tseries ] Time series with cumulated elements.
% Required input arguments:
%   x [ tseries ] Times series to cumulate.
%   dim [ numeric ] Cumulation works along dimension dim.
%
% The IRIS Toolbox 2007/07/25. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 2
  dim = 1;
end

% ###########################################################################################################
% function body

x = unop_(@cumsum,x,0,dim);

end
% end of primary function