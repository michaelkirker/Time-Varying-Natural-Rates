function [T,R,K,Z,H,D,U,Omega] = sspace_(m,alt,expand)
% SSPACE_  General state space with forward expansion.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if nargin < 3
   expand = false;
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
if nargin < 2
   alt = 1 : nalt;
else
   alt = vech(alt);
end

%********************************************************************
%! Function body.

T = m.solution{1}(:,:,alt);
R = m.solution{2}(:,:,alt); % forward expansion
K = m.solution{3}(:,:,alt);
Z = m.solution{4}(:,:,alt);
H = m.solution{5}(:,:,alt);
D = m.solution{6}(:,:,alt);
U = m.solution{7}(:,:,alt);

if ~expand
   R = R(:,1:ne);
end
if isempty(Z)
   Z = zeros([0,nb,length(alt)]);
end
if isempty(H)
   H = zeros([0,ne,length(alt)]);
end
if isempty(D)
   D = zeros([0,1,length(alt)]);
end

if nargout > 7
   Omega = omega_(m,alt);
end

end
% end of primary function