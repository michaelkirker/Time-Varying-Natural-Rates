function [start,data,dim] = init_(dates,data)
%
% TSERIES/PRIVATE/INIT_  Create startdate and data for new time series.
%
% The IRIS Toolbox 2007/10/26. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

dates = dates(:);
nper = length(dates);
nobs = size(data,1);
dim = size(data);
dim = dim(2:end);
if nobs == 0 && (all(isnan(dates)) || nper == 0)
  start = NaN;
  data = zeros([0,dim]);
  return
end

if size(data,1) ~= nper
  error('Number of dates and number of data points in first dimension must match.');
end

% expand higher dimensions into 2D
[data,dim] = reshape_(data);

% remove NaN dates
index = isnan(dates);
if any(index)
  data(index,:) = [];
  dates(index) = [];
end
start = min(dates);
data_ = data;

% number of proper dates
nper = round(max(dates) - start + 1);
if isempty(nper), nper = 0; end

% assign data points at proper dates
data = nan([nper,dim]);
index = round(dates - start + 1);
data(index,:) = data_;
data = reshape_(data,dim);

end

%% end of primary function ----------------------------------------------------------------------------------