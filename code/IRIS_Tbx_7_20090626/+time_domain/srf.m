function [Phi,shksize] = srf(T,R,K,Z,H,D,U,Omega,nper,shksize)
%
% <a href="time-domain/srf">SRF</a>  Shock response function, or VMA representation, for general state space.
%
% The IRIS Toolbox 2007/11/04. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

if nargin < 10
   shksize = 1;
end

% ===========================================================================================================
%! function body

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

% shock size
shksize = vech(shksize);
if length(shksize) == 1 && ne ~= 1
   shksize = shksize(1,ones([1,ne]));
end

Phi = zeros([ny+nx,ne,nper]);
Phi(:,:,1) = [...
   H.*shksize(ones([1,ny]),:);...
   R.*shksize(ones([1,nx]),:);...
];
if ny > 0
   Phi(1:ny,:,1) = Phi(1:ny,:,1) + Z*Phi(ny+nf+1:end,:,1);
end
for t = 2 : nper
   Phi(ny+1:end,:,t) = T*Phi(ny+nf+1:end,:,t-1);
   if ny > 0
      Phi(1:ny,:,t) = Z*Phi(ny+nf+1:end,:,t);
   end
end

if ~isempty(U)
   for t = 1 : nper
      Phi(ny+nf+1:end,:,t) = U*Phi(ny+nf+1:end,:,t);
   end
end

end
% end of primary function