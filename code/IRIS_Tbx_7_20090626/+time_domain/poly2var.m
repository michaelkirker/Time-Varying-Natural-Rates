function A = poly2var(A)
%
% <a href="poly2var">POLY2VAR</a>  Polynomial to VAR conversion.
%
% Syntax:
%   A = var2poly(P)
% Required input arguments:
%   A numeric; P numeric
%
% The IRIS Toolbox 2007/05/10. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

[ny,ny,p,nalt] = size(A);
p = p - 1;
for ialt = 1 : nalt
   if any(A(:,:,1,ialt) ~= eye(ny))
      error('Polynomial must be monic.');
   end
end
A = reshape(-A(:,:,2:end,:),[ny,ny*p,nalt]);

end
% end of primary function -----------------------------------------------------------------------------------