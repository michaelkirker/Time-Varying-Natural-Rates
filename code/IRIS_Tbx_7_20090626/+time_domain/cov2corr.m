function R = cov2corr(C)
%
% TIME-DOMAIN/COV2CORR  Autocovariance to autocorrelation function conversion.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

% ===========================================================================================================
%! function body

R = C;
realsmall = getrealsmall();
nalt = size(R,4);

for ialt = 1 : nalt
   Rk = C(:,:,:,ialt);
   aux = diag(Rk(:,:,1));
   nonzero = abs(aux) > realsmall;
   aux(nonzero) = 1./sqrt(aux(nonzero));
   D = aux(:,ones([1,size(aux,1)]));
   D = D.*transpose(D);
   index = isinf(Rk(:,:,:));
   Rk(index) = 0;
   for i = 1 : size(R,3), Rk(:,:,i) = D.*Rk(:,:,i); end
   Rk(index) = NaN;
   R(:,:,:,ialt) = Rk;
end

end
% end of primary function