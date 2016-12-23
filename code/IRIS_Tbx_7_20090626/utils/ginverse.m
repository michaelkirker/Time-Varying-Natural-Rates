function [A,r] = ginverse(A)
% GINVERSE  Generalised inverse of square matrix.
%
% The IRIS Toolbox 2009/02/18.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% A must be square matrix (no check performed)

if isempty(A)
  A = zeros(size(A),class(A));
  return
end

% Determine rank.
m = size(A,1);
s = svd(A);
tol = m * eps(max(s));
r = sum(s > tol);

% Calculate inverse or pseudo-inverse.
if (r == m)
  A = inv(A);
elseif (r == 0)
  A = zeros(size(A),class(A));
else
  [U,ans,V] = svd(A,0);
  s = diag(1./s(1:r));
  A = V(:,1:r)*s*transpose(U(:,1:r));
end

end
% End of primary function.