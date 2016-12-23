function [X,Y] = fevd(T,R,K,Z,H,D,Za,Omega,nper)
%
% TIME-DOMAIN/FEVD  Forecast error variance decomposition for general state-space variables.
%
% The IRIS Toolbox 2007/07/19. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

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
nalt = size(T,3);

% Call Time Domain package.
Phi = srf(T,R,K,Z,H,D,Za,Omega,nper);

X = cumsum(Phi.^2,3); % FEVD in absolute contributions
Y = zeros(size(X)); % FEVD in relative contributions
status = warning();
warning('off','MATLAB:divideByZero');
varmat = vech(diag(Omega));
varmat = varmat(ones([1,n]),:);
for t = 1 : nper
   X(:,:,t) = X(:,:,t) .* varmat;
   Xsum = sum(X(:,:,t),2);
   Xsum = Xsum(:,ones([1,ne]));
   Y(:,:,t) = X(:,:,t) ./ Xsum;
end
warning(status);

end
% end of primary function