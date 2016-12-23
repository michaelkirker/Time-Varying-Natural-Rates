function [this,data] = demean(this,data)
%
% <a href="VAR/demean.m">DEMEAN</a>  Remove mean from stationary VAR model and its data.
%
% Syntax:
%   [this,dpack] = demean(this,dpack)
% Required input arguments:
%   this [ VAR ] VAR model.
%   dpack [ cell ] VAR variables and residuals.

% The IRIS Toolbox 2008/09/19.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body

[ny,p,nalt] = size(this);
stable = isstationary(this);

% detrend data
if nargin > 1 && nargout > 1
   x = get(data,'data');
   repeat = ones([1,size(x,1)]);
   for iloop = find(stable)
      ymean = transpose(mean(this,iloop));
      x(:,1:ny,iloop) = x(:,1:ny,iloop) - ymean(repeat,:);
   end
   data = set(data,'data',x);
end

% remove constant from VAR
this.K(:,stable) = 0;

if any(~stable)
   warning_(8,sprintf(' #%g',find(~stable)));
end

end
% end of primary function