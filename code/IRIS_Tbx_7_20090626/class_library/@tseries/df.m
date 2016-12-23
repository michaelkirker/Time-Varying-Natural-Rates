function x = df(x,varargin)
%
% DF  First difference.
%
% Syntax:
%   x = df(x)
%   x = df(x,shift)
% Output arguments:
%   x [ tseries ] Time series after first difference.
% Required input arguments:
%   x [ tseries ] Input time series.
%   shift [ numeric ] Time shift, i.e. output times series is computed as x{t} - x{t+shift}.
%
% The IRIS Toolbox 2007/11/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

x = unop_(@df_,x,0,varargin{:});

end

%% end of primary function ----------------------------------------------------------------------------------