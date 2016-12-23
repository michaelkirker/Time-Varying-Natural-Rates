function [S,D,list] = xsf(m,freq,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.xsf">idoc model.xsf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

default = {
   'select',Inf,...
};
options = passopt(default,varargin{:});

if ischar(options.select)
   options.select = charlist2cellstr(options.select);
elseif isempty(options.select)
   options.select = {''};
end

%********************************************************************
%! Function body.

% TODO: Replace with time_domain.function.
import('freq_domain.*');

freq = vech(freq);
nfreq = length(freq);
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
S = nan([ny+nx,ny+nx,nfreq,nalt],m.precision);

[flag,index] = isnan(m,'solution');
for ialt = find(~index)
   [T,R,K,Z,H,D,U,Omega] = sspace_(m,ialt,false);
   S(:,:,:,ialt) = xsf(T,R,K,Z,H,D,U,Omega,freq);
end
S = S / (2*pi);

% Solution not available.
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

% Convert Power spectrum to spectral density.
if nargout > 1
   % Call Freq Domain package.
   D = psf2sdf(S,acf(m));
end

% List of variables.
if nargout > 2 || iscellstr(options.select)
   ny = size(Z,1);
   nx = size(T,1);
   list = ref(printid_(m),1:ny+nx);
end

% Select variables. For backward compatibility only.
% Use SELECT function afterwards instead.
if iscellstr(options.select)
   [S,index,list,notfound] = select(S,list,options.select);
   if ~isempty(notfound)
      warning_(1,notfound);
   end
   if nargout > 1
      D = D(index,index,:,:);
   end
end

end
% End of primary function.