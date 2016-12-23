function x = bpass(x,band,varargin)
%
% <a href="matlab: edit double/bpass">BPASS</a>  Christiano-Fitzgerald band-pass filter.
%
% Called from within <a href="matlab: edit tseries/bpass">tseries/bpass</a>. Check <a href="matlab: help tseries/bpass">help tseries/bpass</a> for help.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

default = {...
  'detrend',true,...
  'log',false,...
  'ttrend',true,...
  'unitroot',true,...
};
options = passopt(default,varargin{:});

if ~isnumeric(band)
  error('Incorrect type of input argument(s).');
end

%% function body --------------------------------------------------------------------------------------------

lo = max([2,min(band)]);;
hi = max(band);

if options.log
  x = log(x);
end

sample0 = false([1,size(x,1)]);
for i = 1 : size(x,2)
  sample = getsample(transpose(x(:,i)));
  if any(sample ~= sample0)
    % calculate projection matrix
    A = christiano_fitzgerald_(sum(sample),lo,hi,double(options.unitroot),0);
  end
  if options.detrend
    xtrend = trend(x(sample,i),1);
    x(sample,i) = x(sample,i) - xtrend;
  end
  x(sample,i) = A*x(sample,i);
  if options.detrend && isinf(hi) && options.ttrend
    % add back deterministic trend
    x(sample,i) = x(sample,i) + xtrend;
  end
  sample0 = sample;
end

if options.log
  x = exp(x);
end

end

%% end of primary function -----------------------------------------------------------------------------------