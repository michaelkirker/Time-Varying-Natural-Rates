function [this,trend] = level(this)
%
% LEVEL  Subtract a time trend from a time series to level the first and last observations.
% 
% Syntax:
%    [x,trend] = level(x)
% Output arguments:
%    x [ tseries ] Levelled time series with the first and last observations equal to zero.
%    trend [ tseries ] Time trend subtracted from the original time series.
% Required input arguments:
%    x [ tseries ] Input time series.

% The IRIS Toolbox 2008/09/26.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! Function body.

data = this.data(:,:);

for i = 1 : size(data,2)
   index = ~isnan(data(:,i));
   n = sum(index);
   if n == 1
      data(index,i) = 0;
   elseif n > 1
      startindex = find(index,1);
      endindex = find(index,1,'last');
      sample = startindex : endindex;
      nper = length(sample);
      d = (data(endindex,i) - data(startindex,i)) / (nper-1);
      trend = data(startindex,i) + d*vec(0 : nper-1);
      data(sample,i) = data(sample,i) - trend;
   end
end

if nargout > 1
   trend = this;
   trend.data(:,:) = this.data(:,:) - data;
end

this.data(:,:) = data;

end
% End of primary function.