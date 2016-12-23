function D = psf2sdf(S,C)
%
% TIME-DOMAIN/PSF2SDF Convert power spectrum to spectral density.
%
% The IRIS Toolbox 2007/06/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

D = S;
realsmall = getrealsmall();
nalt = size(S,4);

for ialt = 1 : nalt
   Dk = S(:,:,:,ialt);
   aux = diag(C(:,:,1,ialt));
   nonzero = abs(aux) > realsmall;
   aux(nonzero) = 1./sqrt(aux(nonzero));
   X = aux(:,ones([1,size(aux,1)]));
   X = X.*transpose(X);
   index = isinf(Dk(:,:,:));
   Dk(index) = 0;
   for i = 1 : size(Dk,3)
      Dk(:,:,i) = X.*Dk(:,:,i);
   end
   Dk(index) = NaN;
   D(:,:,:,ialt) = Dk;
end

end
% end of primary function