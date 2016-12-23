function [A,K,Omega,Sigma,resid,count] = glsq_(w,y0,y1,k0,g1,dummyprior,options)
% Estimate RVAR using generalised least squares.

% The IRIS Toolbox 2009/06/12.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

try
   import('time_domain.*');
end

[ny,nper] = size(y0);
nk = size(k0,1);
ng = size(g1,1);

p = options.order;
nlag = p;
if ng > 0
   nlag = nlag - 1;
end

X = [k0;y1;g1];
ndummy = size(dummyprior,2);
if ndummy > 0
   if size(dummyprior,1) ~= ny + nk + nlag*ny + ng
      % Invalid size of dummy obs matrix.
      error_(21);
   end
   % Include dummy observations.
   y0 = [dummyprior(1:ny,:),y0];
   X = [dummyprior(ny+1:end,:),X];
end

% Ordinary least squares.
beta = y0 / X;
resid = y0(:,ndummy+1:end) - beta*X(:,ndummy+1:end);
Omega = resid*transpose(resid) / nper;
count = 0;
   
% Run generalized least squares only if there are parameter restrictions.
if ~isempty(w.Rr)
   R = w.Rr(:,1:end-1);
   r = w.Rr(:,end);
   maxdiff = Inf;
   while maxdiff > options.tolerance && count <= options.maxiter
      beta0 = beta;
      Omegainv = inv(Omega);
      M = X*transpose(X);
      z = vec(y0) - kron(transpose(X),eye(ny))*r;
      % Estimate free hyperparameters.
      gamma = (transpose(R)*kron(M,Omegainv)*R) \ (transpose(R)*kron(X,Omegainv)*z);
      % Compute parameters.
      beta = reshape(R*gamma + r,[ny,ny*nlag+nk+ng]);
      resid = y0(:,ndummy+1:end) - beta*X(:,ndummy+1:end);
      Omega = resid*transpose(resid) / nper;
      maxdiff = max(vec(abs(beta - beta0)));
      count = count + 1;
   end
end

% Asymptotic cov matrix for parameters.
% Not available for cointegrated systems or systems with priors.
if options.covparameters && ng == 0
   if ndummy > 0
      % If observervations include dummies, we need to base the estimate of Omega
      % on an OLS VAR model.
      beta0 = y0(:,ndummy+1:end) / X(:,ndummy+1:end);
      resid0 = y0(:,ndummy+1:end) - beta0*X(:,ndummy+1:end);
      Omega = resid0*transpose(resid0) / nper;
   end
   if isempty(w.Rr)
      % Unrestricted estimator.
      M = X*transpose(X);
      Sigma = kron(inv(M),Omega);
   else
      % Restricted estimator.
      Sigma = R*((transpose(R)*kron(M,inv(Omega))*R) \ transpose(R));
   end
else
   Sigma = [];
end

% Constant vector.
if nk > 0
   K = beta(:,1);
   beta(:,1) = [];
else
   K = zeros([ny,1]);
end

% Transition matrices.
A = beta(:,1:end-ng);
beta(:,1:end-ng) = [];

% Convert VEC to VAR for cointegrated rVAR.
if ng > 0
   % Co-integrating vector.
   G = beta(:,1:ng);
   if size(options.cointeg,2) == ny+1
      K = K + G*options.cointeg(:,1);
      options.cointeg(:,1) = [];
   end
   aux = polyprod(reshape(A,[ny,ny,nlag]),cat(3,eye(ny),-eye(ny)));
   aux = polysum(aux,eye(ny)+G*options.cointeg);
   A = reshape(aux,[ny,ny*p]);
end

end
% End of primary function.