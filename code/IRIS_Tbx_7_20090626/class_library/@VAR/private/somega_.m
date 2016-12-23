function Omega = somega_(this,alt)
%
% VAR/PRIVATE/SOMEGA_  Covariance matrix of structural VAR innovations.

% The IRIS Toolbox 2008/09/01.
% Copyright (c) 2007-2008 Jaromir Benes.


% ===========================================================================================================
%! function body

[ny,p,nalt] = size(this);

if nargin < 2 || (isnumeric(alt) && any(isinf(alt)))
   alt = 1 : nalt;
else
   alt = vech(alt);
end

Omega = nan([ny,ny,length(alt)]);
var = this.std(1,alt).^2;
for i = 1 : length(alt)
   x = var(i);
   Omega(:,:,i) = diag(x(ones([1,ny])));
end

end
% end of primary function