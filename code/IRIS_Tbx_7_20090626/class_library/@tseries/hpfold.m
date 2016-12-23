function [tnd,gap] = hpf(x,range,varargin)
%
% <a href="matlab: edit tseries/hpf">HPF</a>  Hodrick-Prescott filter with hard tunes.
%
% Syntax:
%   [tnd,gap] = hpf(x)
%   [tnd,gap] = hpf(x,range,...)
% Output arguments:
%   tnd [ tseries ] Estimated trend component.
%   gap [ tseries ] Estimated cyclical component.
% Required input arguments:
%   x [ tseries ] Time series to be filtered.
%   range [ numeric | Inf ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'growth' [ tseries | <a href="default.html">empty</a> ] Hard tunes imposed on the first difference of the estimated trend.
%   'lambda' [ numeric | <a href="default.html">100*get(x,'freq')^2</a> ] Smoothing parameter, i.e. the noise to signal variance ratio.
%   'level' [ tseries | <a href="default.html">empty</a> ] Hard tunes imposed on the level of the estimated trend.
%   'log' [ true | <a href="default.html">false</a> ] Apply filter to logged series.
%   'swap' [ true | <a href="default.html">false</a> ] Swap output arguments: [gap,tnd] = hpf(...) instead of [tnd,gap] = hpf(...).
%
% The IRIS Toolbox 2007/06/28. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

freq = datfreq(x.start);
default = {
  'lambda',100*freq^2,...
  'level',[],...
  'log',false,...
  'growth',[],...
  'swap',false,...
  'forecast',[],...
};
options = passopt(default,varargin{1:end});

if nargin < 2
  range = Inf;
end

if any(isinf(range))
  range = setrange(range);
end

%% function body --------------------------------------------------------------------------------------------

if options.lambda <= 0
  if freq == 0
    error('No default smoothing parameter for time series with indeterminate frequency.');
  else
    error('Unable to use non-positive smoothing parameter.');
  end
end

if isempty(range)
  [varargout{1:nargout}] = deal(empty(x));
  returns
end

[y,range] = getdata_(x,range);

%{
if any(isinf(tmp))
  sample = getsample(transpose(y));
  y = y(sample,:);
  range = range(sample);
end
%}

if any(isnan(y))
  warning('Data contain within-sample NaNs.');
end

if options.log
  y = log(y);
end

sizeofy = size(y);
y = y(:,:);
w = options.lambda;
n = prod(sizeofy(2:end));
nper = sizeofy(1);

if isempty(options.forecast)
  forecast = 0;
else
  forecast = round(options.forecast - range(end));
  if forecast < 0
    forecast = 0;
  end
end
tnddata = nan([nper+forecast,n]);
gapdata = nan([nper+forecast,n]);

if istseries(options.level)
  level = getdata_(options.level,range);
  level = level(:,:);
  if options.log
    level = log(level);
  end
  if size(level,2) == 1 && n > 1
    level = level(:,ones([1,n]));
  end
else
  level = nan([nper,n]);
end

if istseries(options.growth)
  growth = getdata_(options.growth,range);
  growth = growth(:,:);
  if options.log
    growth = log(growth);
  end
  if size(growth,2) == 1 && n > 1
    growth = growth(:,ones([1,n]));
  end
else
  growth = nan([nper,n]);
end

for i = 1 : n

  sample = getsample(transpose(y(:,i)));
  rangei = range(sample);
  T = sum(sample);
  aux = [w,-4*w,(6*w+1)/2];
  d = aux(ones([1,T]),:);

  d(1,2) = -2*w;
  d(end-1,2) = -2*w;
  d(1,3) = (1+w)/2;
  d(end,3) = (1+w)/2;
  d(2,3) = (5*w+1)/2;
  d(end-1,3) = (5*w+1)/2;

  B = spdiags(d,-2:0,T,T);
  B = B + transpose(B);
  yi = y(sample,i);

  % level constraints
  leveli = level(sample,i);
  index = ~isnan(leveli);
  if any(index)
    yi = [yi;leveli(index)];
    for j = vech(find(index))
      B(end+1,j) = 1;
      B(j,end+1) = 1;
    end
  end

  % growth constraints
  growthi = growth(sample,i);
  index = ~isnan(growthi);
  if any(index)
    yi = [yi;growthi(index)];
    for j = vech(find(index))
      B(end+1,[j-1,j]) = [-1,1];
      B([j-1,j],end+1) = [-1;1];
    end
  end

  tndi = B \ yi;
  tndi = tndi(1:T);
  gapi = yi(1:T) - tndi;

  % trend forecast
  if isempty(options.forecast)
    forecasti = 0;
  else
    forecasti = round(options.forecast - rangei(end));
    if forecasti < 0
      forecasti = 0;
    end
  end
  if forecasti > 0
    lastdrift = tndi(end) - tndi(end-1);
    aux = cumsum([tndi(end);lastdrift(ones([1,forecasti]),1)],1);
    tndi(end+(1:forecasti)) = aux(2:end);
    gapi(end+(1:forecasti)) = NaN;
  end

  samplestart = find(sample,1);
  sampleend = find(sample,1,'last') + forecasti;
  tnddata(samplestart:sampleend,i) = tndi;
  gapdata(samplestart:sampleend,i) = gapi;
end % of for

if options.log
  tnddata = exp(tnddata);
  gapdata = exp(gapdata);
end

tnd = x;
tnd.start = range(1);
tnd.data = reshape(tnddata,[size(tnddata,1),sizeofy(2:end)]);
tnd = cut_(tnd);

gap = x;
gap.start = range(1);
gap.data = reshape(gapdata,[size(gapdata,1),sizeofy(2:end)]);
gap = cut_(gap);

if options.swap
  [tnd,gap] = deal(gap,tnd);
end

end

%% end of primary function ----------------------------------------------------------------------------------