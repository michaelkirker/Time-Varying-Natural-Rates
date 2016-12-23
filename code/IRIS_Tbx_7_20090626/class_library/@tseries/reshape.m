function [x,oldsize] = reshape(x,newsize)
%
% RESHAPE  Reshape size of time series in 2nd and higher dimensiions.
%
% Syntax:
%   [x,oldsize] = reshape(x)
%   [x,oldsize] = reshape(x,newsize)
% Required input arguments:
%   x [ tseries ] Time series to be reshaped.
%   oldsize [ numeric ] Old size of time series.
%   newsize [ numeric ] Desired size of time series.
%
% The IRIS Toolbox 2007/07/06. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
% function body

oldsize = size(x.data);
if nargin < 2
  newsize = prod(oldsize(2:end));
else
  if ~isinf(newsize(1)) && newsize(1) ~= size(x.data,1)
    error('To RESHAPE time series the first input dimension must be Inf or match the number of periods.');
  end
  newsize = newsize(2:end);
end
x.data = reshape(x.data,[size(x.data,1),newsize]);
x.comment = reshape(x.comment,[1,newsize]);

end
% end of primary function