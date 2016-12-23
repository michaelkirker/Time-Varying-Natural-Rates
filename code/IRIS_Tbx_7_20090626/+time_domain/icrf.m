function [Phi,icsize] = icr(T,R,K,Z,H,D,U,Omega,nper,linear,logged)
%
% <a href="time-domain/icrf">ICRF</a>  Initial condition response function for general state space.
%
% The IRIS Toolbox 2007/11/04. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

if nargin < 10
   icsize = 1;
end

% ===========================================================================================================
%! function body

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;

% size of deviations in initial conditions
% linear models: 1.00 
% non-linear modesl: 0.01 for linearised variables, log(1.01) for log-linearised variables
icsize = zeros([1,nb]);
if linear
   icsize(:) = 1;
else
   icsize(logged) = log(1.01);
   icsize(~logged) = 0.01;
end

Phi = zeros([ny+nx,nb,nper+1]);
Phi(ny+nf+1:end,:,1) = diag(icsize);
if ~isempty(U)
   Phi(ny+nf+1:end,:,1) = U\Phi(ny+nf+1:end,:,1);
end

for t = 2 : nper + 1
   Phi(ny+1:end,:,t) = T*Phi(ny+nf+1:end,:,t-1);
   if ny > 0
      Phi(1:ny,:,t) = Z*Phi(ny+nf+1:end,:,t);
   end
end

Phi = Phi(:,:,2:end);

if ~isempty(U)
   for t = 1 : nper
      Phi(ny+nf+1:end,:,t) = U*Phi(ny+nf+1:end,:,t);
   end
end

end
% end of primary function