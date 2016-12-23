function x = arf(x,A,z,range,varargin)
% <a href="matlab: edit tseries/arf">ARF</a>  Fill or expand time series with autoregressive process.
%
% Syntax:
%   x = arf(x,A,z,range,...)
% Output arguments:
%   x [ tseries ] Output time series such that A(L)*x = z.
% Required input arguments:
%   x [ tseries ] Input time series.
%   A [ numeric ] Autoregressive polynomial A(L) = A(1) + A(2)*L + ... + A(p)*L^p.
%   z [ tseries | numeric ] Exogenous term.
%   range [ numeric | Inf ] Time range, i.e. <a html="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'time' [ 'backward' | <a href="default.html">'forward'</a> ] Flow of time.

% The IRIS Toolbox 2009/04/22.
% Copyright (c) 2007-2009 Jaromir Benes.

if nargin < 4
   range = Inf;
end

if ~istseries(x) || ~isnumeric(A) || (~isnumeric(z) && ~istseries(z)) || ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

default = {...
   'time','forward',@(x) strcmpi(x,{'backward','forward'}),...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

A = vech(A);
order = length(A) - 1;

% Work out range (includes pre/post-sample initial condition).
xfirst = x.start;
xlast = x.start + size(x.data,1) - 1;
if any(isinf(range))
   range = xfirst : xlast;
else
   if strcmp(options.time,'forward')
      range = min(range)-order : max(range);
   else
      range = min(range) : max(range)+order;
   end
end

% Get endogenous (x) data.
xdata = getdata_(x,range);
[xdata,xdim] = reshape_(xdata);

% Do noting if effective range is empty.
nper = length(range);
if nper <= order
   return
end

% Get exogenous (z) data.
if istseries(z)
   zdata = getdata_(z,range);
   zdata = reshape_(zdata);
   % expand zdata in 2nd dimension if needed
else
   if isempty(z)
      z = 0;
   end
   zdata = z(ones([1,nper]),:);
end
if size(zdata,2) == 1 && size(xdata,2) > 1
   zdata = zdata(:,ones([1,size(xdata,2)]));
end

% Normalise polynomial vector.
if A(1) ~= 1
   zdata = zdata / A(1);
   A = A / A(1);
end

% Run AR.
if strcmp(options.time,'forward')
   shifts = -1 : -1 : -order;
   timevec = 1+order : nper;
else
   shifts = 1 : order;
   timevec = nper-order : -1 : 1;
end
for i = 1 : size(xdata,2)
   for t = timevec
      xdata(t,i) = -A(2:end)*xdata(t+shifts,i) + zdata(t,i);
   end
end

% Update output series.
x = setdata_(x,range,reshape_(xdata,xdim));
x = cut_(x);

end
% End of primary function.