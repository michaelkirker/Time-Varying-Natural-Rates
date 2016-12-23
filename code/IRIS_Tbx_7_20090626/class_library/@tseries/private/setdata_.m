function x = setdata_(x,dates,data,varargin)

% for backward compatibility:
% vectorise data if assigned time series is scalar and non-empty
xsize = size(x.data);
if sum(xsize(2:end) > 1) == 0 && sum(size(data) > 1) <= 1 && ~isnan(x.start)
  data = vec(data);
end

if nargin > 3
  subs = varargin;
else
  subs(1:length(xsize)-1) = {':'};
end

dates = dates(:);
if any(isinf(dates))
  dates = x.start + (0 : xsize(1)-1);
end

nper = length(dates);
nobs = size(data,1);

if nper == 0 && nobs == 0
  return
end

% expand data in time dimension if needed
if nobs == 1 && nper > 1
  data = data(ones([1,nper]),:);
  nobs = nper;
end

if isnan(x.start)

  % assign to an empty time series
  index = 1 : nobs;
  x.start = dates(1);

else

  % exclude NaN dates and incorrect frequencies
  index = abs((dates-floor(dates)) - (x.start-floor(x.start))) < 0.01 & ~isnan(dates);
  dates(~index) = [];
  [data,dim] = reshape_(data);
  data(~index,:) = [];
  data = reshape_(data,dim);

  dim = size(x.data);
  nper = dim(1);
  dim = dim(2:end);
  index = round(dates - x.start + 1);
  if any(index > nper)
    x.data = [x.data;nan([max(index)-nper,dim])];
  end
  if any(index < 1)
    minindex = min(index);
    x.data = [nan([1-minindex,dim]);x.data];
    x.start = x.start - 1 + minindex;
    index = index + 1 - minindex;
  end

end

s.type = '()';
s.subs = [{index},subs];
x.data = subsasgn(x.data,s,data);

end