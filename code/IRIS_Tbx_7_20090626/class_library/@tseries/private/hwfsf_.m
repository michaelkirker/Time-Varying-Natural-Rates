function [x,F] = hwfsf_(x,datfreq,band,varargin)
%
% Called from within tseries/hwfsf.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if ~isnumeric(band)
  error('Incorrect type of input argument(s).');
end

default = {...
  'detrend',true,@islogical,...
  'log',false,@islogical,...
  'addtrend',true,@islogical,...
  'season',false,@islogical,...
  'window','hamming',@(x) any(strcmp(x,{'hamming','hanning','none'})),...
};
options = passvalopt(default,varargin{:});

switch options.window
case 'hanning'
  a = 0.5;
case 'hamming'
  a = 0.53;
case 'none'
  a = 1;
end

% ###########################################################################################################
%% function body

% log filter
if options.log
  x = log(x);
end

if options.season
  season = datfreq;
else
  season = 0;
end

% cut off periodicities below Nyquist
band(band < 2) = 2;
minband = min(band);
maxband = max(band);
% peridocidity to frequency conversion
lo = 2*pi/maxband;
hi = 2*pi/minband;

nper_ = 0;
F = nan(size(x));

if options.detrend
  xtrend1 = nan(size(x));
  xtrend2 = nan(size(x));
end
addzero = options.detrend && options.addtrend && isinf(maxband);
addseason = options.detrend && options.addtrend && options.season && season >= minband && season <= maxband;

for i = 1 : size(x,2)
  sample = getsample(transpose(x(:,i)));
  nper = sum(sample);
  if nper == 0
    continue
  end
  if nper ~= nper_
    freq = transpose(2*pi*(0:nper-1)/nper);
    H = (freq >= lo & freq <= hi);
    % impose symmetry
    H(2:end) = H(2:end) | H(end:-1:2);
    W = toeplitz([a,(1-a)/2,zeros([1,nper-2])]);
    W(1,end) = (1-a)/2;
    W(end,1) = (1-a)/2;
    nper_ = nper;
  end
  if options.detrend
    [xtrend1(sample,i),xtrend2(sample,i)] = dftrend_(x(sample,i),season);
    x(sample,i) = x(sample,i) - xtrend1(sample,i) - xtrend2(sample,i);
  end
  F(sample,i) = W*H;
  x(sample,i) = ifft(F(sample,i).*fft(x(sample,i)));
end

% add deterministic trend
if addzero
  x = x + xtrend1;
end

% add deterministic seasonals
if addseason
  x = x + xtrend2;
end

% delog
if options.log
  x = exp(x);
end

end
% end of primary function