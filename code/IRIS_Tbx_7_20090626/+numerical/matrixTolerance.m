function [tol,s,u,v] = matrixTolerance(X)

if nargout < 3
   s = svd(X);
else
   [u,s,v] = svd(X);
end
tol = max(size(X))*eps(s(1,1));

end