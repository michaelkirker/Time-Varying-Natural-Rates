function [X,Y,x,y] = fevd(this,time)
% <a href="VAR/fevd">FEVD</a>  Forecast error variance decomposition (structural VAR only).
%
% Syntax:
%   [X,Y,x,y] = fevd(this,nper)
%   [X,Y,x,y] = fevd(this,range)
% Output arguments:s
%   X [ numeric ] Forecast error variance decomposition: absolute contributions of shocks.
%   Y [ numeric ] Forecast error variance decomposition: relative contributions of shocks
%   x [ tseries ] Multivariate time series with absolute contributions.
%   y [ tseries ] Multivariate time series with relative contributions.
% Required input arguments:
%   this [ VAR ] Structural VAR model.
%   nper [ numeric ] Number of periods.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2009/06/23.
% Copyright 2007-2009 Jaromir Benes.

if isempty(this.B)
   % cannot apply FEVD to reduced-form VAR
   error_(18,'FEVD');
end

% tell whether time is nper or range
if length(time) == 1 && round(time) == time && time > 0
   range = 1 : time;
else
   range = time(1) : time(end);
end
nper = length(range);

%********************************************************************
%! Function body.

try
   import('time_domain.*');
end

[ny,p,nalt] = size(this);

Phi = var2vma(this.A,this.B,nper);
X = cumsum(Phi.^2,3);
Y = nan(size(X));
query = warning('query','MATLAB:divideByZero');
warning('off','MATLAB:divideByZero');
for ialt = 1 : nalt
   variance = this.std(ialt).^2;
   for t = 1 : nper
      X(:,:,t,ialt) = X(:,:,t,ialt) .* variance;
      Xsum = sum(X(:,:,t,ialt),2);
      Xsum = Xsum(:,ones([1,ny]));
      Y(:,:,t,ialt) = X(:,:,t,ialt) ./ Xsum;
   end
end
warning(query);

if nargout > 2
   x = tseries(range,permute(X,[3,1,2,4]));
end

if nargout > 3
   y = tseries(range,permute(Y,[3,1,2,4]));
end

end
% End of primary function.