function x = dot(x,varargin)
%
% DOT  First difference of logs.
%
% Syntax:
%   x = dot(x)
%   x = dot(x,shift)
% Output arguments:
%   x [ tseries ] First difference of log of input series.
% Required input arguments:
%   x [ tseries ] Input time series.
%   shift [ numeric ] Time shift: output series is computed as log(x{t}) - log(x{t+k}).
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin > 1 && ~isnumeric(varargin{1})
  error('Incorrect type of input argument(s).');
end

%% function body --------------------------------------------------------------------------------------------

x = unop_(@dot_,x,0,varargin{:});

end

%% end of primary function ----------------------------------------------------------------------------------