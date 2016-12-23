function [Phi,list] = vma(m,nper,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.vma">idoc model.vma</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

Phi = zeros([ny+nx,ne,nper,nalt],m.precision);
[flag,index] = isnan(m,'solution');
for ialt = find(~index)
   [T,R,K,Z,H,D,U,Omega] = sspace_(m,ialt,false);
   % Call Time Domain package.
   Phi(:,:,:,ialt) = srf(T,R,K,Z,H,D,U,Omega,nper,1);
end

% solution not available
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

if nargout > 1
   list = printid_(m);
   list = {list(1:ny+nx),list(ny+nx+(1:ne))};
end

end
% end of primary function