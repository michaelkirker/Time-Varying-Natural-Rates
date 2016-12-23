function coher = xsf2coher(S,varargin)
%
% <a href="freq_domain/coher">XSF2COHER</a>  Convert power spectrum function to coherence.
%
% Syntax:
%   coher = xsf2coher(S)
% Output arguments:
%   coher [ numeric ] Coherence.
% Required input arguments:
%   S [ numeric ] Power spectrum function.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

amplitude2 = abs(S).^2; % faster than real(S).^2 + imag(S).^2;
coher = zeros(size(S));
realsmall = getrealsmall();

for i = 1 : size(S,3)
   d = diag(S(:,:,i));
   index = abs(d) <= realsmall;
   d(~index) = 1./d(~index);
   d(index) = 0;
   D = diag(d);
   coher(:,:,i) = D * amplitude2(:,:,i) * D;
end

for i = 1 : size(S,1)
   coher(i,i,:) = 1;
end

end
% end of function body