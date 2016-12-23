function W = ifrf(T,R,K,Z,H,D,Zp,Omega,freq)
%
% FREQ-DOMAIN/IFRF Frequency response function to input signals for general state space.
%
% The IRIS Toolbox 2008/05/06. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(R,2);

nfreq = length(freq);
T = [zeros([nf+nb,nf]),T];

W = zeros([ny+nf+nb,ne,0]);
for lambda = vech(freq)
   W(ny+1:end,:,end+1) = (eye(nf+nb)-T*exp(-1i*lambda))\R;
   W(1:ny,:,end) = Z*W(ny+nf+1:end,:,end);
   W(1:ny,:,end) = W(1:ny,:,end) + H;
   W(ny+nf+1:end,:,end) = Zp*W(ny+nf+1:end,:,end);
end

end
% of primary function