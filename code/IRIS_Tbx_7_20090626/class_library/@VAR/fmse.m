function [X,x] = fmse(this,time,varargin)
% <a href="VAR/fmse">FMSE</a>  Forecast mean square error matrices.
%
% Syntax:
%   [M,x] = fmse(this,nper)
%   [M,x] = fmse(this,range)
% Output arguments:
%   M [ numeric ] Forecast MSE matrices.
%   x [ tseries ] Multivariate time series with std deviations for individual variables.
% Required input arguments:
%   this [ VAR ] VAR model.
%   nper [ numeric ] Number of periods.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2008/06/23.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'output',[],@(x) true,...
};
options = passvalopt(default,varargin{:});

if ~isempty(options.output)
   warning('VAR/FMSE option ''output'' is not supported any longer.');
end

% Tell whether time is nper or range.
if length(time) == 1 && round(time) == time && time > 0
   range = 1 : time;
else
   range = time(1) : time(end);
end
nper = length(range);

%********************************************************************
%! Function body.

[ny,p,nalt] = size(this);

% Orthonormalise residuals
% so that we do not have to multiply the VMA representation by Omega.
B = nan([ny,ny,nalt]);
for ialt = 1 : nalt
   B(:,:,ialt) = transpose(chol(this.Omega(:,:,ialt)));
end

% Get VMA representation for general state space,
X = time_domain.var2vma(this.A,B,nper);

% Compute FMSE matrices.
for ialt = 1 : nalt
   for t = 1 : nper
      X(:,:,t,ialt) = X(:,:,t,ialt)*transpose(X(:,:,t,ialt));
   end
end
X = cumsum(X,3);

% Compute stddevs for individual series.
tmp = tseries();
if nargout > 1
   x = nan([nper,ny,nalt]);
   for i = 1 : ny
      x(:,i,:) = sqrt(permute(X(i,i,:,:),[3,1,4,2]));
   end
   x = replace(tmp,x,range(1));
end

end
% End of primary function.