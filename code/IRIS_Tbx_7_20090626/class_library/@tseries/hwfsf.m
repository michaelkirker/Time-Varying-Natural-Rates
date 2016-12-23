function [x,F] = hwfsf(x,range,band,varargin)
%
% <a href="matlab: edit tseries/hwfsf">HWFSF</a>  Iacobucci-Noullez H-windowed frequency-selective filter.
%
% Syntax:
%   [x,F] = hwbpf(x,range,band,...)
% Output arguments:
%   x [ tseries ] Filtered time series.
%   F [ numeric ] Spectral window weights.
% Required input arguments:
%   x [ tseries ] Time series to be filtered.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   band [ numeric ] Spectral band to be retained.
% <a href="options.html">Optional input arguments:</a>
%   'detrend' [ <a href="default.html">true</a> | false ] Remove deterministic time trend.
%   'log' [ true | <a href="default.html">false</a> ] Filter evaluated on log(x).
%   'addtrend' [ <a href="default.html">true</a> | false ] Add detereministic trend to output series if band contains Inf and/or seasonal frequency.
%   'season' [ true | <a href="default.html">false</a> ] Include zero-sum seaonals into deterministic trend.
%   'window' [ <a href="default.html">'hamming'</a> | 'hanning' | 'none' ] Type of spectral window.
%
% Iacobucci, A. & A. Noullez (2005). A Frequency Selective Filter for Short-Length Time Series.
% Computational Economics, 25, 75--102.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if ~isnumeric(band) || ~isnumeric(range)
  error('Incorrect type of input argument(s).');
end

range = setrange(range,x.start:x.start+size(x.data,1)-1);

% ###########################################################################################################
%% function body

if isempty(range)
  [x.data,dim] = reshape_(x.data);
  x.data = x.data([],:);
  x.data = reshape_(x.data,dim);
  x.start = NaN;
  return
end

data = getdata_(x,range);
datasize = size(data);
data = data(:,:);
[data(:,:),F] = hwfsf_(double(data),datfreq(x.start),band,varargin{:});
x.data = reshape(data,datasize);
x.start = range(1);
x = cut_(x);

end
% end of primary function