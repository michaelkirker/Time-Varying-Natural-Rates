function [X,list,d] = fmse(m,time,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.fmse">idoc model.fmse</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {
  'select',Inf,...
};
options = passopt(default,varargin{:});

if ischar(options.select)
  options.select = charlist2cellstr(options.select);
end

% tell whether time is nper or range
if length(time) == 1 && round(time) == time && time > 0
  range = 1 : time;
else
  range = time(1) : time(end);
end
nper = length(range);

% =======================================================================================
%! Function body.

try
   import('time_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
X = zeros([ny+nx,ny+nx,nper,nalt],m.precision);

% Compute FMSE for all available parameterisations.
[flag,index] = isnan(m,'solution');
for ialt = find(~index)
  [T,R,K,Z,H,D,U,Omega] = sspace_(m,ialt,false);
  % Call Time Domain package.
  X(:,:,:,ialt) = fmse(T,R,K,Z,H,D,U,Omega,nper);
end

% Some solution(s) not available.
if flag
  warning_(44,sprintf(' #%g',find(index)));
end

% Write formatted variables.
if nargout > 1 || iscellstr(options.select)
  ny = size(Z,1);
  nx = size(T,1);
  list = ref(printid_(m),1:ny+nx);
end

% Database of std deviations.
if nargout > 2
  % select only contemporaneous variables
  id = [m.solutionid{1:2}];
  d = struct();
  for i = find(imag(id) == 0)
    name = m.name{id(i)};
    d.(name) = tseries(range,sqrt(permute(X(i,i,:,:),[3,4,1,2])));
  end
  for j = find(m.nametype == 4)
    d.(m.name{j}) = vech(m.assign(1,j,:));
  end
end

% Select variables.
% This is an obsolete option, use the select function afterwards instead.
if iscellstr(options.select)
  [X,index,list,notfound] = select(X,list,options.select);
  if ~isempty(notfound)
    warning_(1,notfound);
  end
end

end
% End of primary function.