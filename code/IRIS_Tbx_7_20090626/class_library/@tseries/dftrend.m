function [x1,x2] = dftrend(x,range,varargin)
%
% <a href="matlab: edit tseries/trend">TREND</a>  Estimate deterministic time trend on first differences.
%
% Syntax:
%   [x1,x2] = trend(x)           
%   [x1,x2] = trend(x,range,...)
% Output arguments:
%   x1 [ tseries ] Linear time trend.
%   x2 [ tseries ] Deterministic seasonals.
% Required input arguments:
%   x [ tseries ] Input series to which time trend will be fitted.
%   range [ numeric | Inf ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'log' [ true | <a href="default.html">false</a> ] Fit trend to logarithmised series.
%   'season' [ true | <a href="default.html">false</a> ] Include zero-sum seasonal dummies.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

default = {...
  'log',false,@islogical,...
  'season',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if nargin < 2
  range = Inf;
end

% ###########################################################################################################
%% function body

% include seasonals
if options.season
  season = datfreq(x.start);
else
  season = 0;
end

% empty range => empty series
if isempty(range)
  x = empty(x);
  return
end

% resize time series
if ~any(isinf(range))
  xdata = getdata_(x,range);
  x.data = xdata;
  x.start = range(1);
end

if options.log
  x.data = log(x.data);
end

x1 = x;
x2 = x;
[x1.data,x2.data] = dftrend_(x.data,season);

if options.log
  x1.data = exp(x1.data);
  x2.data = exp(x2.data);
end

end
% end of primary function