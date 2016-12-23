function this = schur_(this)
% SCHUR_  Triangular representation of VAR.

% The IRIS Toolbox 2009/06/23.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,p,nalt] = size(this);

if p == 0
  this.T = zeros([ny,ny,nalt]);
  this.U = eye(ny);
  this.U = this.U(:,:,ones([1,nalt]));
  this.eigval = zeros([1,ny,nalt]);
  return
end

realsmall = getrealsmall();
A = companion(this);
this.U = nan([ny*p,ny*p,nalt]);
this.T = nan([ny*p,ny*p,nalt]);
this.eigval = nan([1,ny*p,nalt]);
for ialt = 1 : nalt
   if any(any(isnan(A(:,:,ialt))))
      continue
   else   
      [this.U(:,:,ialt),this.T(:,:,ialt)] = schur(A(:,:,ialt));
      eigval = vech(ordeig(this.T(:,:,ialt)));
      unstable = abs(eigval) > 1 + realsmall;
      unit = abs(abs(eigval) - 1) <= realsmall;
      stable = abs(eigval) < 1 - realsmall;
      clusters = zeros(size(eigval));
      clusters(unstable) = 2;
      clusters(unit) = 1;
      [this.U(:,:,ialt),this.T(:,:,ialt)] = ordschur(this.U(:,:,ialt),this.T(:,:,ialt),clusters);
      this.eigval(1,:,ialt) = vech(ordeig(this.T(:,:,ialt)));
   end
end

end
% End of primary function.