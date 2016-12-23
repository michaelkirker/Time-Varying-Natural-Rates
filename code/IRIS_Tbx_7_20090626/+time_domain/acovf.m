function [C,diffuse] = acovf(T,R,K,Z,H,D,U,Omega,eigval,order)
% Autocovariance function for general state space.

% The IRIS Toolbox 2008/10/14.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

try
   import('time_domain.*');
end

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

if ny == 0
  Z = zeros([0,nb]);
  H = zeros([0,ne]);
  D = zeros([0,1]);
end

Tf = T(1:nf,:);
Ta = T(nf+1:end,:);
Rf = R(1:nf,:);
Ra = R(nf+1:end,:);

[dy,df,da] = isdiffuse(eigval,Z,Tf,eye(nb));
if ~isempty(U)
  db = isdiffuse(eigval,U);
else
  db = da;
end
Caa = zeros(nb);

% Solve Lyapunov equation for contemporaneous covariance matrix.
Caa(~da,~da) = lyapunov(Ta(~da,~da),Ra(~da,:)*Omega*transpose(Ra(~da,:)));

Ra_Omega_Rf = Ra*Omega*transpose(Rf);
Cff = Tf*Caa*transpose(Tf) + Rf*Omega*transpose(Rf);
Cyy = Z*Caa*transpose(Z) + H*Omega*transpose(H);
Cyf = Z*Ta*Caa*transpose(Tf) + Z*Ra_Omega_Rf;
Cya = Z*Caa;
Cfa = Tf*Caa*transpose(Ta) + transpose(Ra_Omega_Rf);

C = [...
  Cyy,Cyf,Cya;...
  transpose(Cyf),Cff,Cfa;...
  transpose(Cya),transpose(Cfa),Caa;...
];
diffuse = [dy,df,db];
ne = 0;

if order > 0
  TT = [Z*Ta;Tf;Ta];
  for i = 1 : order
    C(1:end-ne,:,i+1) = TT*C(ny+nf+1:end-ne,:,i);
  end
end

if ~isempty(U)
  for i = 0 : order
    C(ny+nf+1:end-ne,:,i+1) = U*C(ny+nf+1:end-ne,:,i+1);
    C(:,ny+nf+1:end-ne,i+1) = C(:,ny+nf+1:end-ne,i+1)*transpose(U);
  end
end
C(diffuse,:,:) = Inf;
C(:,diffuse,:) = Inf;

end
% End of primary function.