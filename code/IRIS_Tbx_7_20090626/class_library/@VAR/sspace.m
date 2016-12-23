function [T,R,k,Z,H,d,U,Omega] = sspace(this,alt)
%
% SSPACE  Quasi-triangular state-space form for VAR.

% The IRIS Toolbox 2009/06/23.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,p,nalt] = size(this);

if nargin < 2
   alt = Inf;
end
if any(isinf(alt))
   alt = 1 : nalt;
elseif islogical(alt)
   alt = find(alt);
end
alt = vech(alt);

T = this.T(:,:,alt);
U = this.U(:,:,alt);
R = permute(U(1:ny,:,:),[2,1,3]);
K = this.K(:,alt);

% Constant term.
k = zeros([ny*p,1,length(alt)]);
for i = 1 : length(alt)
   k(:,1,i) = transpose(U(1:ny,:,i))*K(:,1,i);
end

Z = U(1:ny,:,:);

H = zeros([ny,ny,length(alt)]);
d = zeros([ny,1,length(alt)]);

Omega = this.Omega(:,:,alt);

if ~isempty(this.B)
   % SVAR.
   B = this.B(:,:,alt);
   for i = 1 : length(alt)
      R(:,:,i) = R(:,:,i)*B(:,:,i);
   end
   Omega = somega_(this,alt);
end

end
% End of primary function.