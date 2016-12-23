function [F,list] = ffrf(m,freq,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.ffrf">idoc model.ffrf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/09/26.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {
  'exclude',[],...
  'maxiter',500,...
  'select',Inf,...
  'tolerance',1e-7,...
};
options = passopt(default,varargin{:});

if ischar(options.select)
   options.select = {options.select};
end

if ischar(options.exclude)
   options.exclude = {options.exclude};
end

% ===========================================================================================================
%! Function body.

try
   import('freq_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

if ~isempty(options.exclude)
   options.exclude = regexprep(options.exclude,'@?log\((.*?)\)','$1');
   exclude = findnames(m.name(m.nametype == 1),options.exclude);
   index = isnan(exclude);
   if any(index)
     warning_(1,options.exclude(index));
   end
   exclude(index) = [];
   aux = false([1,sum(m.nametype == 1)]);
   aux(exclude) = true;
   exclude = aux;
else
   exclude = false([1,ny]);
end

freq = vech(freq);
nfreq = length(freq);
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
F = nan([nx,ny,nfreq,nalt],m.precision);

if ny > 0
   [flag,index] = isnan(m,'solution');
   for ialt = find(~index)
      [T,R,k,Z,H,d,U,Omega] = sspace_(m,ialt,false);
      % Remove measurement variables excluded by user.
      Z(exclude,:) = [];
      H(exclude,:) = [];
      d(exclude,:) = [];
      % Call Freq Domain package.
      % Compute FFRF.
      F(:,~exclude,:,ialt) = ...
         ffrf(T,R,k,Z,H,d,U,Omega,m.eigval(1,:,ialt),freq,options.tolerance,options.maxiter);
   end
   % Solution not available.
   if flag
      warning_(44,sprintf(' #%g',find(index)));
   end
end

% Print variable names.
if nargout > 1 || iscellstr(options.select)
   tmp = printid_(m);
   list = {tmp(ny+(1:nx)),tmp(1:ny)};
end

% Select requested variables.
if iscellstr(options.select)
   [F,index,list,notfound] = select(F,list,options.select);
   if ~isempty(notfound)
      warning_(1,notfound);
   end
else

end
% End of primary function.