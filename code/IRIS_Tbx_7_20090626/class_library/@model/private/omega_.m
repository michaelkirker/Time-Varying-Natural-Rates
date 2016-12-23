function Omega = omega_(m,altindex)
% OMEGA_  Covariance matrix of residuals.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

ne = sum(m.nametype == 3);
if nargin < 2
   altindex = 1 : size(m.assign,3);
else
   altindex = vech(altindex);
end
nselect = length(altindex);

pindex = find(m.nametype == 4);
Omega = zeros([ne,ne,nselect]);
stdvec = m.assign(1,pindex(end-ne+1:end),altindex);
for i = 1 : nselect
   Omega(:,:,i) = diag(stdvec(1,:,i).^2);
end

if nselect == 1
   % Return sparse matrix
   % if only one parameterisation is requested.
   Omega = sparse(Omega);
end

end
% End of primary function.