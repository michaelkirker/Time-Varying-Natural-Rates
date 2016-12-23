function n = length(x)
%
% <a href="tseries/size">LENGTH</a>  Length of time series.
%
% Syntax
%   n = length(x)
% Output arguments for syntax (1):
%   n [ numeric ] Number of periods.
% Required input arguments:
%   x [ tseries ] Time series.
%
% The IRIS Toolbox 2007/11/20. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

n = size(x.data,1);

end

%% end of primary function ----------------------------------------------------------------------------------