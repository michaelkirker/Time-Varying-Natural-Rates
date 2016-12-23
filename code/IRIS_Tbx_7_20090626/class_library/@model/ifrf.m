function [W,list] = ifrf(m,freq,varargin);
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.ifrf">idoc model.ifrf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

default = {...
   'select',Inf,...
};
options = passopt(default,varargin{:});

% ===========================================================================================================
%! function body

try
   % Try to import Freq Domain package.
   import('freq_domain.*');
end

freq = vech(freq);
nfreq = length(freq);
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
W = {zeros([ny+nx,ne,nfreq,nalt],m.precision),freq};

if ne > 0
   [flag,index] = isnan(m,'solution');
   for ialt = find(~index)
      [T,R,K,Z,H,D,Za,Omega] = sspace_(m,ialt,false);
      % Call Freq Domain package.
      W{1}(:,:,:,ialt) = ifrf(T,R,K,Z,H,D,Za,Omega,freq);
   end
end

% solution not available
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

% print variable names
if nargout > 1 || iscellstr(options.select)
   tmp = printid_(m);
   list = {tmp(1:ny+nx),tmp(ny+nx+1:end)};
end

% select variables (for backward compatibility only)
% use SELECT function afterwards instead
if iscellstr(options.select)
   [W{1},index,list,notfound] = select(W{1},list,options.select);
   if ~isempty(notfound)
      warning_(1,notfound);
   end
end

end
% end of primary function