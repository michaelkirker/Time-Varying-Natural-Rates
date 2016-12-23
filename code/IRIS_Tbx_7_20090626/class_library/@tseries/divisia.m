function x = divisia(x,w,range)
% <a href="tseries/divisia">DIVISIA</a> Discrete Divisia index.
%
% Syntax:
%   y = divisia(x,w,range)
% Required input arguments:
%   y [ tseries ] Divisia index.
%   x [ tseries ] Input times series.
%   w [ tseries | numeric ] Fixed or time-varying weights.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2009/04/07. 
% Copyright (c) 2007-2009 Jaromir Benes.

if nargin < 3
   range = Inf;
end

% For backward compatibility, accept divisia(x,range,w),
% and swap w and range.
if isnumeric(w) && (any(isinf(w)) || (size(w,1) == 1 && size(w,2) ~= size(x,2)))
   [w,range] = deal(range,w);
end

%********************************************************************
%! Function body.

% Generate range.
range = genrange(x,range);
range = range(getsample(transpose(x.data)));
nper = length(range);

% Get range data.
x.data = rangedata(x,range);
x.start = range(1);

% Get weights.
if istseries(w)
   w = rangedata(w,range);
elseif size(w,1) == 1
   w = w(ones([1,nper]),:);
end

% Normalise weights.
wsum = sum(w,2);
for i = 1 : size(w,2)
   w(:,i) = w(:,i) ./ wsum(:);
end

% Average weight t and t-1.
wavg = (w(2:end,:) + w(1:end-1,:))/2;

% Construct Divisia index. Set pre-sample observation to 1.
x.data = [0;sum(wavg .* log(x.data(2:end,:)./x.data(1:end-1,:)),2)];
x.data = exp(cumsum(x.data));
x.comment = {''};

end
% End of primary function.