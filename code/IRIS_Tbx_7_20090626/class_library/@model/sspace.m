function [T,R,K,Z,H,D,U,Omega,list] = sspace(m,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.sspace">idoc model.sspace</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/13.
% Copyright (c) 2007-2009 Jaromir Benes.

nalt = size(m.solution{1},3);
if nargin > 1 && isnumeric(varargin{1})
   alt = vech(varargin{1});
   varargin(1) = [];
else
   alt = 1 : nalt;
end

default = {...
   'triangular',true,@islogical,...
   'removeinactive',false,@islogical,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

[T,R,K,Z,H,D,U,Omega] = sspace_(m,alt,true);
ny = size(Z,1);
nx = size(T,1);

if nargout > 8
   tmp = printid_(m);
   list = {tmp(1:ny),tmp(ny+(1:nx)),tmp(ny+nx+1:end)};
end

if ~options.triangular
   % T <- U*T/U;
   % R <- U*R;
   % K <- U*K;
   % Z <- Z/U;
   % U <- eye
   [ny,nx,nf,nb,ne,np,nalt] = size_(m);
   for i = 1 : length(alt)
      T(:,:,i) = T(:,:,i) / U(:,:,i);
      T(nf+1:end,:,i) = U(:,:,i)*T(nf+1:end,:,i);
      R(nf+1:end,:,i) = U(:,:,i)*R(nf+1:end,:,i);
      K(nf+1:end,:,i) = U(:,:,i)*K(nf+1:end,:,i);
      Z(:,:,i) = Z(:,:,i) / U(:,:,i);
      U(:,:,alt(i)) = eye(size(U));
   end
end

if options.removeinactive
   if length(alt) == 1
      index = diag(Omega) ~= 0;
      R = reshape(R,[nx,ne,size(R,2)/ne]);
      R = R(:,index,:);
      R = R(:,:);
      H = H(:,index);
      Omega = Omega(index,index);
      if nargout > 8
         list{3} = list{3}(index);
      end
   else
      warning_(47);
   end
end
% end of primary function