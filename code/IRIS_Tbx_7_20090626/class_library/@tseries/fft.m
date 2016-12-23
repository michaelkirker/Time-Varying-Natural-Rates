function [y,range,freq,per] = fft(x,range)
%
% <a href="matlab: edit tseries/fft">FFT</a>  Discrete Fourier transform of time series.
% 
% Syntax:
%   [y,range,freq,per] = fft(x,range)
% Output arguments:
%   y [ numeric ] Fourier transform (column-wise).
%   range [ numeric ] Time range actually used.
%   freq [ numeric ] Frequencies corresponding to FFT vector elements.
%   per [ numeric ] Periodicities corresponding to FFT vector elements.
% Required input arguments:
%   x [ tseries ] Times series to be transformed.
%   range [ numeric | Inf ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2007/07/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

if nargin < 2 || any(isinf(range))
  range = 'min';
else
  range = vech(range);
end

if isempty(range)
  y = nan(size(x));
  return
end

[y,range] = double(x,range);
nper = length(range);

si = size(y);
y = fft(y(:,:));

freq = 2*pi*(0:nper-1) / nper;

% convert frequencies to periodicities
index = freq == 0;
per = nan(size(freq));
per(~index) = 2*pi./freq(~index);
per(index) = Inf;

index = freq <= pi;
freq = freq(index);
y = y(index,:);
y = reshape(y,[sum(index),si(2:end)]);

end

%% end of primary function ----------------------------------------------------------------------------------