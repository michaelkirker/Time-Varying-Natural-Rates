function [Py,Pfa,Pe] = simulatemse(T,R,K,Z,H,D,U,stdvec,initmse,nper)
% SIMULATEMSE  Simulate MSE matrices in general state space.

% The IRIS Toolbox 2009/06/23.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[nx,nb] = size(T);
[ny,ne] = size(H); 
nf = nx - nb;

symmet_ = @(X) (X + X')/2;

Py = nan([ny,ny,nper]);
Pfa = nan([nx,nx,nper]);
Pe = nan([ne,ne,nper]);
varvec = stdvec.^2;
for t = 1 : nper
   Pe(:,:,t) = diag(varvec(:,t));
   Pesparse = sparse(Pe(:,:,t));
   Sigmax = symmet_(R(:,1:ne)*Pesparse*R(:,1:ne)');
   Sigmay = symmet_(H*Pesparse*H');
   if t == 1
      if isempty(initmse) || all(all(initmse == 0))
         Pfa(:,:,t) = Sigmax;
      else
         Pfa(:,:,t) = symmet_(T*initmse*T' + Sigmax);
      end
   else
      Pfa(:,:,t) = symmet_(T*Pfa(nf+1:end,nf+1:end,t-1)*T' + Sigmax);
   end
   Py(:,:,t) = symmet_(Z*Pfa(nf+1:end,nf+1:end,t)*Z' + Sigmay);
end

end
% End of primary function.