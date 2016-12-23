function [C,list] = acfd(this,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.acf">idoc model.acf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse The IRIS Toolbox documentation in the Contents pane.

% The IRIS Toolbox 2008/10/14.
% Copyright 2007-2009 Jaromir Benes.

default = {
   'order',0,@isnumericscalar,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

try
   import('time_domain.*','freq_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(this);
C = nan([ny+nx,ny+nx,options.order+1,ne,nalt]);

% Solution not available for these parameterisations.
[flag,nans] = isnan(this,'solution');
if flag
   warning_(44,sprintf(' #%g',find(nans)));
end

% Autocovariance functions conditional upon individual shocks.
for ialt = find(~nans)
   [T,R,K,Z,H,D,U,Omega] = sspace_(this,ialt,false);
   for ie = 1 : ne
      C(:,:,:,ie,ialt) = acovf(T,R(:,ie),K,Z,H(:,ie),D,U,Omega(ie,ie),this.eigval(1,:,ialt),options.order);
   end
end

% Fix negative variances.
tmpsize = size(C);
if length(tmpsize) < 5
   tmpsize(end+1:5) = 1;
end
C0 = reshape(C(:,:,1,:,:),[tmpsize(1:2),prod(tmpsize(4:5))]);
C0 = fixcov(C0);
C(:,:,1,:,:) = reshape(C0,[tmpsize(1:2),1,tmpsize(4:5)]);

% List of variables and shocks.
if nargout > 1
   list = printid_(this);
   list = list(1:ny+nx);
end

end
% End of primary function.
