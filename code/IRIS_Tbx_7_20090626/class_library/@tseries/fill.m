function x = fill(x,dates,data)
%
% <a href="matlab: edit tseries/fill">FILL</a>  Fill time series with value(s).
%
% Syntax:
%   x = fill(x,dates,data)
% Output arguments:
%   x [ tseries ] Filled output series.
% Required input arguments:
%   x [ tseries ] Time series to be filled.
%   dates [ numeric ] Dates or time range at which to fill the time series, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   data [ numeric ] Scalar value or vector of values to fill the time series with.
%
% The IRIS Toolbox 2007/09/30. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if ~isnumeric(dates) || (~isnumeric(data) && ~isa(data,'logical'))
  error('Incorrect type of input argument(s).');
end

%% function body --------------------------------------------------------------------------------------------

dates = setdates(dates);

if isempty(data)
  data = NaN;
elseif length(data) > 1
  if isscalar(x), data = data(:); end
  [data,dim] = reshape_(data);
  data(end+(1:length(dates)-length(data)),:) = data(end,:);
  data = reshape_(data,dim);
end

x = setdata_(x,dates,data);
x = cut_(x);

end

%% end of primary function ----------------------------------------------------------------------------------