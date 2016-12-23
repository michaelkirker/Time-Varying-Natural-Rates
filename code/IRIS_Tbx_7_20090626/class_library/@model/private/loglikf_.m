function [mlogl,se2] = loglikf_(m,I,frq,delta,options)
% LOGLIKF  Evaluate likelihood function in frequency domain.

% The IRIS Toolbox 2009/05/04.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[T,R,K,Z,H,D,U,Omega] = sspace_(m,1,false);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);
realsmall = getrealsmall();
nunit = sum(abs(abs(m.eigval - 1)) <= realsmall);

% Z(1:nunit,:) assumed to be zero.

T = T(nf+nunit+1:end,nunit+1:end);
R = R(nf+nunit+1:end,:);
Z = Z(~options.exclude,nunit+1:end);
H = H(~options.exclude,:);
Sigmaaa = R*Omega*transpose(R);
Sigmayy = H(~options.exclude,:)*Omega*H(~options.exclude,:)';
na = size(T,1);
ny = sum(~options.exclude);

nfrq = length(frq);
frqlo = 2*pi/max(options.band);
frqhi = 2*pi/min(options.band);

ixfrq = frq >= frqlo & frq <= frqhi;
% Drop zero frequency
% unless requested.
if ~options.zero
   ixfrq(frq == 0) = false;
end
ixfrq = find(ixfrq);

L0 = 0;
L1 = 0;
G = nan([ny,ny,nfrq]);
nobs = 0;
for i = ixfrq
  nobs = nobs + delta(i)*ny;
  ZiW = Z / ((eye(na) - T*exp(-1i*frq(i))));
  G(:,:,i) = ZiW*Sigmaaa*ctranspose(ZiW) + Sigmayy;
  iG = inv(G(:,:,i));
  iGt = transpose(iG);
  vecI = I(:,:,i);
  vecI = vecI(:);
  L0 = L0 + delta(i)*real(log(det(G(:,:,i))));
  % L1 = L1 + trace(iGt*I_) where trace iG*I = vech(iG')*vec(I_)
  % should be multiplied by 2*pi but we skip dividing by 2*pi in I
  L1 = L1 + delta(i)*real(iGt(:).' * vecI);
  % mlogl = mlogl + log(det(G(:,:,i)))/2 + pi*trace(iG*I_);
end

if options.relative
   se2 = L1/nobs;
   L0 = L0 + nobs*log(se2);
   L1 = L1/se2;
else
   se2 = 1;
end
mlogl = (nobs*log(2*pi) + L0 + L1) / 2;

end
% End of primary function.