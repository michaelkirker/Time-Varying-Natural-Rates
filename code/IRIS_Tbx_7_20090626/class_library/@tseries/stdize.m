function x = stdize(x,varargin)
%
% STDIZE  Standardize time series by subtracting mean and dividing by std deviation.
%
% Syntax:
%   x = stdize(x)
%   x = stdize(x,flag)
% Output arguments:
%   x [ tseries ] Standardised time series.
% Required input arguments:
%   x [ tseries ] Input time series.
%   flag [ numeric ] Flag=0 (default) normalises by N-1, flag=1 normalises by N, where N is sample length.
%
% The IRIS Toolbox 2007/11/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

x = unop_(@stdize,x,0,varargin{:});

end

%% end of primary function ----------------------------------------------------------------------------------