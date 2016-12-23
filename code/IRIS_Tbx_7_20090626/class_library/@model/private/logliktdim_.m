function [F,Fi,Zt_Fi,K,L,P,ainit] = logliktdim_(m,use,y,T,k,Z,Sigmaa,Sigmay)
% Data-independent matrices for loglikt_. Called from within loglikt_.

% The IRIS Toolbox 2008/10/16.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,nb] = size(Z);
realsmall = getrealsmall();
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
nunit = sum(abs(abs(use.eigval) - 1) <= realsmall);
nper = size(y,2);
isT11eye = iseye(T(1:nunit,1:nunit));
isuserinit = all(~isnan(use.userinitmean)) && all(all(~isnan(use.userinitmse)));
ix1 = 1 : nunit;
ix2 = nunit+1 : nb;

% Pre-allocate output matrices.

F = nan([ny,ny,nper]);
Fi = nan([ny,ny,nper]);
Zt_Fi = zeros([nb,ny,nper]);
K = zeros([nb,ny,nper]);
L = nan([nb,nb,nper]);
P = nan([nb,nb,nper]);
ainit = zeros([nb,1]);

% MSE matrices for the prediction step.

if isuserinit
   Pinit = use.userinitmse;
else
   Pinit = zeros(nb);
   if nb > nunit && strcmpi(use.initcond,'stochastic')
      % Call Time Domain package.
      Pinit(ix2,ix2) = time_domain.lyapunov(T(ix2,ix2),Sigmaa(ix2,ix2,1));
   end
end
         
P(:,:,1) = Pinit;
L(:,:,1) = T;
P(:,:,2) = T*P(:,:,1)*transpose(T) + Sigmaa(:,:,2);
         
for t = 2 : nper
   ixy = ~isnan(y(:,t));
   ixz = any(Z(ixy,:) ~= 0,1);
   F(ixy,ixy,t) = Z(ixy,ixz)*P(ixz,ixz,t)*transpose(Z(ixy,ixz)) + Sigmay(ixy,ixy,t);
   if use.chkfmse
      Fi(ixy,ixy,t) = ginverse(F(ixy,ixy,t));
   else
      Fi(ixy,ixy,t) = inv(F(ixy,ixy,t));
   end
   Zt_Fi(ixz,ixy,t) = transpose(Z(ixy,ixz))*Fi(ixy,ixy,t);
   if isT11eye
   % make use of T11 = I, T21 = 0
      T_P = [...
         P(ix1,ix1,t)+T(ix1,ix2)*P(ix2,ix1,t),P(ix1,ix2,t)+T(ix1,ix2)*P(ix2,ix2,t);...
         T(ix2,ix2)*P(ix2,ix1,t),T(ix2,ix2)*P(ix2,ix2,t);...
      ];
   else
      % make use of T21 == 0
      T_P = [...
         T(ix1,:)*P(:,:,t);...
         T(ix2,ix2)*P(ix2,ix1,t),T(ix2,ix2)*P(ix2,ix2,t);...
      ];
   end
   K(:,ixy,t) = T_P(:,ixz)*Zt_Fi(ixz,ixy,t);
   if any(ixy)
      L(:,:,t) = T - K(:,ixy,t)*Z(ixy,:);
   else
      L(:,:,t) = T;
   end
   if t < nper
      P(:,:,t+1) = T_P*transpose(L(:,:,t)) + Sigmaa(:,:,t+1);
   end
end

% Initial condition for alpha vector.

if isuserinit
   ainit(:) = use.userinitmean;
elseif nb > nunit && ~use.deviation
   ainit(ix2) = (eye(nb-nunit) - T(ix2,ix2)) \ k(ix2,1);
end

end
% End of primary function.