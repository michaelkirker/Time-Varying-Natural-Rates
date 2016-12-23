function C = acovfyw(A,C,order)
%
% TIME-DOMAIN/ACOVFYW  VAR autocovariance function for higher orders based on Yule-Walker equations.

% The IRIS Toolbox 2007/05/03.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body 

[ny,aux] = size(A);
p = aux/ny;

% residuals included or not in ACF
ne = size(C,1) - ny;

A = reshape(A(:,1:ny*p),[ny,ny,p]);
C = C(:,:,1+(0:p-1));
for i = p : order
   aux = zeros([ny,ny+ne]);
   for j = 1 : size(A,3)
      aux = aux + A(:,:,j)*C(1:ny,:,end-j+1);
   end
   C(1:ny,:,1+i) = aux;
end

end
% end of primary function