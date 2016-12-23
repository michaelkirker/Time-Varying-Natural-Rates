function [ny,nx,nf,nb,ne,np,nalt] = size_(m)
% SIZE_  Lengths of model state space vectors.

% The IRIS Toolbox 2009/02/13.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

ny = sum(m.nametype == 1);
ne = sum(m.nametype == 3);
np = sum(m.nametype == 4);
[nx,nb,nalt] = size(m.solution{1});
nf = nx - nb;

end
% End of primary function.