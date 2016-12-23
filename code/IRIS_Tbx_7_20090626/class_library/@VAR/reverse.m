function this = reverse(this)
%
% <a href="matlab: edit VAR/reverse">REVERSE</a>  Reverse VAR model.
%
% Syntax:
%   this = reverse(this)
% Output arguments:
%   this [ VAR ] Reverse VAR model.
% Required input arguments:
%   this [ VAR ] VAR model.

% The IRIS Toolbox 2008/09/19.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body 

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,p,nalt] = size(this);

index = isstationary(this);
for ialt = 1 : nalt
   if index(ialt)
      [T,R,K,Z,H,D,U,Omega] = sspace(this,ialt);
      % 0th and 1st order autocovariance matrices of stacked y vector.
      C = acovf(T,R,[],[],[],[],U,Omega,this.eigval(1,:,ialt),1);
      A = transpose(C(:,:,2)) / C(:,:,1);
      Q = A*C(:,:,2);
      Omega = C(:,:,1) + A*C(:,:,1)*transpose(A) - Q - transpose(Q);
      A = A(end-ny+1:end,:);
      A = reshape(A,[ny,ny,p]);
      A = A(:,:,end:-1:1);
      this.A(:,:,ialt) = A(:,:);
      this.Omega(:,:,ialt) = Omega(end-ny+1:end,end-ny+1:end);
      this.K(:,ialt) = sum(var2poly(this.A(:,:,ialt)),3)*mean(this,ialt);
   else
      % Non-stationary parameterisations.
      this.A(:,:,ialt) = NaN;
      this.Omega(:,:,ialt) = NaN;
      this.K(:,ialt) = NaN;
   end
end

if any(~index)
   warning_(12,sprintf(' #%g',find(~index)));
end

this = schur_(this);

end
% end of primary function