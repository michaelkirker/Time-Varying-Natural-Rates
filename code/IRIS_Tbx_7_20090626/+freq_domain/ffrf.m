function f = ffrf(T,R,K,Z,H,D,U,Omega,eigval,freq,tolerance,maxiter)
%
% FREQ-DOMAIN/FFRF  Frequence response function for general state space.

% The IRIS Toolbox 2008/09/26.
% Copyright (c) 2007 Jaromir Benes.

% ===========================================================================================================
%! Function body.

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

T = [zeros([nx,nf]),T];
Z = [zeros([ny,nf]),Z];
Sigmaa = R*Omega*transpose(R);
Sigmay = H*Omega*transpose(H);

% Steady-state Kalman filter.
Pp = eye(size(T));
Pf = Pp;
Pp0 = inf(size(T));
Pf0 = Pp0;
maxdiff = Inf;
count = 0;
while maxdiff > tolerance && count < maxiter
   Pp0 = Pp;
   Pf0 = Pf;
%  Pf = Pp - Pp(:,nf+1:end)*transpose(Z(:,nf+1:end))*inv(Z(:,nf+1:end)*Pp(nf+1:end,nf+1:end)*transpose(Z(:,nf+1:end))+Sigmay)*Z(:,nf+1:end)*Pp(nf+1:end,:);
   Q = ginverse(Z(:,nf+1:end)*Pp(nf+1:end,nf+1:end)*transpose(Z(:,nf+1:end))+Sigmay);
   Pf = Pp - Pp(:,nf+1:end)*transpose(Z(:,nf+1:end))*(Q*Z(:,nf+1:end))*Pp(nf+1:end,:);
   Pp = T(:,nf+1:end)*Pf(nf+1:end,nf+1:end)*transpose(T(:,nf+1:end)) + Sigmaa;
%  Pf = Pp - Pp*transpose(Z)*((Z*Pp*transpose(Z)+Sigmay)\Z*Pp);
%  Pp = T*Pf*transpose(T) + Sigmaa;
   maxdiff = max(abs([vec(Pp);vec(Pf)]-[vec(Pp0);vec(Pf0)]));
   count = count + 1;
end

if maxdiff > tolerance
   warning('Convergence not reached for steady-state Kalman filter.');
end

if rank(Pp) < size(Pp,1)
   J = Pf*transpose(T)*pinv(Pp);
else
   J = Pf*transpose(T)/Pp;
end
tmp = Z*Pp*transpose(Z)+Sigmay;
if rank(tmp) < size(Sigmay,1)
   C = Pp*transpose(Z)*pinv(tmp);
else
   C = Pp*transpose(Z)/tmp;
end
K = T*C;
I = eye(size(T));

f = zeros([nx,ny,length(freq)]);
z = exp(-1i*freq);
zinv = exp(1i*freq);
for k = 1 : length(freq)
   B = ginverse(I - (T - K*Z)*z(k));
   A = B * K;
   f(:,:,k) = (I-J*zinv(k)) \ ((I-C*Z)*A*z(k) + C - J*A);
   if ~isempty(U)
      f(nf+1:end,:,k) = U*f(nf+1:end,:,k);
   end
end

end
% End of primary function.