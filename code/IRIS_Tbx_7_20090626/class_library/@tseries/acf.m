function [C,R] = acf(x,dates,varargin)
%
% <a href="tseries/acf">ACF</a>  Sample autocovariance and autocorrelation functions.
%
% Syntax:
%   [C,R] = acf(x,dates,...)
% Output arguments:
%   C [ numeric ] Autocovariance function.
%   R [ numeric ] Autocorrelation function.
% Required input arguments:
%   x [ tseries ] Univariate or multivariate time series.
%   dates [ numeric | Inf ] Dates or time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'order' [ numeric | <a href="default.html">0</a> ] Maximum order up to which ACF is to be computed.
%   'smallsample' [ <a href="default.html">true</a> | false ] Adjust degrees of freedom for small samples.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ===========================================================================================================
%! function body 

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

if nargin < 2
   sample = getsample(permute(x.data,[2,1,3]));
   data = x.data(sample,:);
elseif any(isinf(dates))
   data = getdata_(x,'min');
else
   data = getdata_(x,dates);
end
nalt = size(data,3);
for ialt = 1 : nalt
   % Call Time Domain package.
   C(:,:,:,ialt) = acovfsmp(data(:,:,ialt),varargin{:});
   if nargout > 1
      % Call Time Domain package.
      % Convert covariances to correlations.
      R(:,:,:,ialt) = cov2corr(C(:,:,:,ialt));
   end
end

end
% end of primary function