function x = bpass(x,range,band,varargin)
%
% <a href="matlab: edit tseries/bpass">BPASS</a>  Christiano-Fitzgerald band-pass filter.
%
% Syntax:
%   x = bpass(x,range,band,...)
% Output arguments:
%   x [ tseries ] Band-pass filtered output series.
% Required input arguments:
%   x [ tseries ] Input series to be filtered.
%   range [ numeric | Inf ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   band [ numeric ] Band of periodicities to be retained in output series: [low,high].
% <a href="options.html">Optional input arguments:</a>
%   'detrend' [ <a href="default.html">true</a> | false ] Remove linear time trend before filtering.
%   'log' [ true | <a href="default.html">false</a> ] Filter evaluated on log(x).
%   'ttrend' [ <a href="default.html">true</a> | false ] Add linear time trend back to filtered output series (only if band includes Inf).
%   'unitroot' [ <a href="default.html">true</a> | false ] Assume unit root in time series.
%
% Christiano, L.J. and T.J.Fitzgerald (2003). The Band Pass Filter.
% International Economic Review, 44(2), 435--465.
%
% See also the <a href="http://www.clevelandfed.org/research/model/bandpass/bpassm.txt">original Christiano-Fitzgerald m-file</a>.
%
% The IRIS Toolbox 2007/09/30. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if ~isnumeric(band) || ~isnumeric(range)
  error('Incorrect type of input argument(s).');
end
if length(band) ~= 2 && length(range) == 2
  [range,band] = deal(band,range);
end
range = setrange(range,x.start:x.start+size(x.data,1)-1);

%% function body --------------------------------------------------------------------------------------------

if isempty(range)
  [x.data,dim] = reshape_(x.data);
  x.data = x.data([],:);
  x.data = reshape_(x.data,dim);
  x.start = NaN;
  return
end

data = getdata_(x,range);
[data,dim] = reshape_(data);
data(:,:) = bpass_(double(data),band,varargin{:});
x.data = reshape_(data,dim);
x.start = range(1);
x = cut_(x);

end

%% end of primary function ----------------------------------------------------------------------------------