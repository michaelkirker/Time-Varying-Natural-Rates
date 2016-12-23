function S = xsfvar(A,Omega,freq,filter,applyto,order)
%
% FREQ-DOMAIN/XSFVAR  Power spectrum function for VAR variables.
%
% The IRIS Toolbox 2007/08/14. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

isfilter = nargin > 3;

[ny,p] = size(A);
p = p/ny;
A = reshape(A,[ny,ny,p]);
nfreq = length(freq);

if isfilter
   n = 1+order;
else
   n = nfreq;
end

S = zeros([ny,ny,n]);
e = exp(complex(0,-1)*(1:p));
for i = 1 : nfreq
   lambda = freq(i);
   F = eye(ny);
   for j = 1 : p
      F = F - exp(-1i*j*lambda)*A(:,:,j);
   end
   s = F \ Omega / ctranspose(F);
   if isfilter
      s(applyto,:) = filter(i)*s(applyto,:);
      s(:,applyto) = s(:,applyto)*conj(filter(i));
      S(:,:,1) = S(:,:,1) + s;
      for j = 1 : order
         S(:,:,1+j) = S(:,:,1+j) + s*exp(1i*freq(i)*j);
      end
   else
      S(:,:,i) = s;
   end
end

% skip dividing S by 2*pi

if ~isfilter
   for i = 1 : size(S,1)
      S(i,i,:) = real(S(i,i,:));
   end
end

end
% end of primary function