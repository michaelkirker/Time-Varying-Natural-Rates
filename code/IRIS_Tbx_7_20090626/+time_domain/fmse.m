function X = fmse(T,R,K,Z,H,D,U,Omega,nper)
%
% TIME-DOMAIN/FMSE  Forecast mean square error matrices for general state space.
%
% The IRIS Toolbox 2007/08/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);
n = ny + nf + nb;

% Call Time Domain package.
Phi = srf(T,R,K,Z,H,D,U,Omega,nper);

X = nan([n,n,nper]);
for t = 1 : nper
   X(:,:,t) = Phi(:,:,t)*Omega*transpose(Phi(:,:,t));
end
X = cumsum(X,3);

end
% end of primary function -----------------------------------------------------------------------------------