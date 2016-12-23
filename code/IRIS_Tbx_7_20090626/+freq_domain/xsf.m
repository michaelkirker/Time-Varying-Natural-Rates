function S = xsf(T,R,K,Z,H,D,U,Omega,freq,filter,applyto,order)
% XSF  Power spectrum function for general state space.

% The IRIS Toolbox 2009/01/23.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

isfilter = nargin > 9;

realsmall = getrealsmall();
ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
nunit = sum(all(abs(eye(nb) - T(nf+1:end,:)) < realsmall,1));
ne = size(R,2);

Tf = T(1:nf,:);
Rf = R(1:nf,1:ne);
Ta = T(nf+1:end,:);
Ra = R(nf+1:end,:);
Ta12 = T(nf+1:nf+nunit,nunit+1:end);
Ta22 = T(nf+nunit+1:end,nunit+1:end);
% Sigmax = R*Omega*transpose(R); %<<
Sigmaaa = Ra*Omega*transpose(Ra);
Sigmaff = Rf*Omega*transpose(Rf);
Sigmayy = H*Omega*transpose(H);
Sigmayf = Z*Ra*Omega*transpose(Rf);
Sigmafa = Rf*Omega*transpose(Ra);

% T = [zeros([nf+nb,nf]),T];

freq = vech(freq);
nfreq = length(freq);

if isfilter
   n = 1+order;
else
   n = nfreq;
end
S = zeros([ny+nf+nb,ny+nf+nb,n]);
s = zeros([ny+nf+nb,ny+nf+nb,1]);

status = warning();
warning('off');
for i = 1 : nfreq
   ee = exp(-1i*freq(i));
   % F = eye(nf+nb) -  [zeros([nf+nb,nf]),T]*exp(-1i*freq(i));
   % xxx = F \ Sigmax / ctranspose(F);
   s(ny+1:end,ny+1:end) = inv_();
   s(1:ny,1:ny) = Z*s(ny+nf+1:end,ny+nf+1:end)*transpose(Z) + Sigmayy;
   s(1:ny,ny+1:end) = Z*s(ny+nf+1:end,ny+1:end);
   s(ny+1:end,1:ny) = s(ny+1:end,ny+nf+1:end)*transpose(Z);
   if freq(i) == 0
      % diffuse y
      index = find(any(abs(Z(:,1:nunit)) > realsmall,2));
      s(index,:) = Inf;
      s(:,index) = Inf;
   end
   if freq(i) == 0
      % diffuse xf
      index = find(any(abs(Tf(:,1:nunit)) > realsmall,2));
      s(ny+index,:) = Inf;
      s(:,ny+index) = Inf;
   end
   if ~isempty(U)
      s(ny+nf+1:end,:) = U*s(ny+nf+1:end,:);
      s(:,ny+nf+1:end) = s(:,ny+nf+1:end)*transpose(U);
      if freq(i) == 0
         % diffuse xb
         index = find(any(abs(U(:,1:nunit)) > realsmall,2));
         s(ny+nf+index,:) = Inf;
         s(:,ny+nf+index) = Inf;
      end
   end
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
warning(status);

% Skip dividing S by 2*pi.

if ~isfilter
   for i = 1 : ny+nx
      S(i,i,:) = real(S(i,i,:));
   end
end

% End of function body.

%********************************************************************
%! Nested function inv_().

function [Sxx,Saa] = inv_()
   A = Tf*ee;
   % B = inv(eye(nb) - Ta*ee) = inv([A11,A12;0,A22]);
   % A11 = eye(nunit) - eye(unit)*ee
   % A12 = -Ta12*ee
   % A22 = eye(nb-nunit) - Ta22*ee
   B22 = inv(eye(nb-nunit) - Ta22*ee);
   if freq(i) == 0
      B11 = zeros(nunit);
      B12 = zeros([nunit,nb-nunit]);
   else
      d = 1/(1-ee);
      B11 = diag(d(ones([1,nunit])));
      B12 = d*Ta12*B22*ee;
   end
   B = [B11,B12;zeros([nb-nunit,nunit]),B22];
   Saa = B*Sigmaaa*ctranspose(B);
   Sfa = Sigmafa*ctranspose(B) + A*Saa;
   X = A*B*transpose(Sigmafa);
   Sff = Sigmaff + X + ctranspose(X) + Tf*Saa*transpose(Tf);
   Sxx = [Sff,Sfa;ctranspose(Sfa),Saa];
end
% End of nested function inv_().

end
% End of primary function.