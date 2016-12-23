function x = wmean(this,dates,beta)
%
% <a href="matlab: edit tseries/wmean">WMEAN</a>  Weighted average of time series observations.
%
% Syntax:
%    x = wmean(this,range,beta)
% Output arguments:
%    x [ numerice ] Weighted average (greater weight on more recent observations).
% Required input arguments:
%    this [ tseries ] Time series.
%    range [ numeric ] Time range, <a href="dates.html">IRIS serial date numbers</a>.
%    beta [ numeric ] Discount factor.

% The IRIS Toolbox 2008/09/26.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 2
   dates = Inf;
end

if nargin < 3
   beta = 1;
end

% ===========================================================================================================
%! Function body.

% Get time series data.
s = struct();
s.type = '()';
s.subs{1} = dates;
data = subsref(this,s);

% Compute wieghted average.
tmpsize = size(data);
data = data(:,:);
if beta ~= 1
   w = vec(beta.^(tmpsize(1)-1:-1:0));
   for i = 1 : size(this.data,2)
      data(:,i) = data(:,i) .* w;
   end
   sumw = sum(w);
else
   sumw = tmpsize(1);
end
x = sum(data/sumw,1);
x = reshape(x,[1,tmpsize(2:end)]);

end
% End of primary function.