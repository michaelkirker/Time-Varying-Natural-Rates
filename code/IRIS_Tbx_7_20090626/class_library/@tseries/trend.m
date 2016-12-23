function [x,varargout] = trend(x,varargin)
%
% <a href="matlab: edit tseries/trend">TREND</a>  Fit time trend of desired order to time series.
%
% Syntax:
%   [x,beta] = trend(x)                    (1)
%   [x,beta] = trend(x,range,order,...)    (2)
% Output arguments:
%   x [ tseries ] Fitted time trend.
%   beta [ numeric ] Estimated coefficients.
% Required input arguments:
%   x [ tseries ] Input series to which time trend will be fitted.
% Required input arguments for syntax (2):
%   range [ numeric | Inf ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   order [ numeric ] Order of time trend.
% <a href="options.html">Optional input arguments:</a>
%   'log' [ true | <a href="default.html">false</a> ] Fit trend to logarithmised series.
%   'season' [ true | <a href="default.html">false</a> ] Include zero-sum seasonal dummies.
%
% Nota bene:
%   Syntax (1) assumes order=0, i.e. the sample mean of the series is computed.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

% check for old syntax x = trend(x,order)
range = Inf;
order = 0;
if nargin > 1 && isnumeric(varargin{1}) && ~any(isinf(varargin{1})) && length(varargin{1}) == 1 && round(abs(varargin{1})) == varargin{1}
  order = varargin{1};
  varargin(1) = [];
elseif nargin > 1
  range = varargin{1};
  varargin(1) = [];
  if ~isempty(varargin)
    order = varargin{1};
    varargin(1) = [];
  end
end

default = {...
  'log',false,@islogical,...
  'season',false,@islogical,...
};
options = passvalopt(default,varargin{:});

%% function body --------------------------------------------------------------------------------------------

% include seasonals
if options.season
  order = order + get(x,'freq')/100;
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

[x,varargout{1:nargout-1}] = unop_(@trend_,x,0,order);

if options.log
  x.data = exp(x.data);
end

end

%% end of primary function ----------------------------------------------------------------------------------