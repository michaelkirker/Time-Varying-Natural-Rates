function A = var2poly(A)
%
% <a href="time_domain/var2poly">VAR2POLY</a>  VAR to polynomial conversion.
%
% Syntax:
%   P = var2poly(A)
% Output arguments:
%   P [ numeric ] 3D matrix representing polynomial in lag operator.
% Required input arguments:
%   A [ numeric | VAR ] 2D matrix or VAR representing estimated transition matrix.
%
% The IRIS Toolbox 2007/05/10. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

% ===========================================================================================================
%! function body

if isvar(A)
   A = get(A,'A');
end
[ny,p,nalt] = size(A);
p = p/ny;
x = eye(ny);
x = x(:,:,1,ones([1,nalt]));
A = cat(3,x,reshape(-A,[ny,ny,p,nalt]));

end
% end of primary function