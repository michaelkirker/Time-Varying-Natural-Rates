function G = xsf2gain(S)
% 
% <a href="freq_domain/xsf2gain">XSF2GAIN</a>  Convert power spectrum function to gain.
%
% Syntax:
%   gain = xsf2gain(S)
% Output arguments:
%   gain [ numeric ] Gain.
% Required input arguments:
%  S [ numeric ] Power spectrum function.
%
% The IRIS Toolbox 2007/06/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

amplitude2 = abs(S).^2; % faster than real(S).^2 + imag(S).^2;
D = zeros(size(S));
G = zeros(size(S));
status = warning();
warning('off','MATLAB:divideByZero');
for i = 1 : size(S,3)
    D(:,:,i) = diag(1./diag(S(:,:,i)));
    G(:,:,i) = sqrt(amplitude2(:,:,i)) * D(:,:,i);
end
warning(status);  

for i = 1 : size(S,1)
   G(i,i,:) = 1;
end

end
% end of primary function