function [rkq,crit,EH,VH,Sv] = rkqtest(H,level,pval,varargin)
%
% The IRIS Toolbox 4/11/2007. Copyright 2007 Jaromir Benes.

default = {...
  'display',true,...
};
options = passopt(default,varargin{:});

% function body ---------------------------------------------------------------------------------------------

[np,np,ndraw] = size(H);
N = np*np;

% normalise by parameter values

if ~isempty(pval)
  pval = pval(:);
  X = pval(:,ones([1,np]));
  X = X.*transpose(X);
  H0 = H;
  for i = 1 : ndraw
    H(:,:,i) = H(:,:,i).*X;
  end
end

% compute EH & VH

if nargout > 4
  Sv = zeros([np,ndraw]);
  for i = 1 : ndraw
    Sv(:,i) = svd(H(:,:,i));
  end
end

H = reshape(H,[N,ndraw]);
EH = sum(H,2)/ndraw;

VH = 0;
for i = 1 : ndraw
  x = H(:,i);
  x_Ex = x*transpose(EH);
  VH = VH + x*transpose(x) - x_Ex - transpose(x_Ex);
end
VH = VH/ndraw + EH*transpose(EH);

EH = reshape(EH,[np,np]);

% perform rkq test

level = vech(level);
iVH = eye(size(VH));
iVH = pinv(VH);
rkq = [];
crit = [];
[U,Lambda,V] = svd(EH);
for q = np-1 : -1 : 1
  lambdaq = vech(Lambda(q+1:end,q+1:end));
  U2 = U(:,q+1:end);
  V2 = V(:,q+1:end);
  Omega = kron(transpose(V2),transpose(U2)) * iVH * kron(V2,U2);
  rkq(end+1,1) = ndraw*(lambdaq)*Omega*transpose(lambdaq);
  crit(end+1,:) = chi2inv(level,(np-q).^1);
end

end % of primary function -----------------------------------------------------------------------------------