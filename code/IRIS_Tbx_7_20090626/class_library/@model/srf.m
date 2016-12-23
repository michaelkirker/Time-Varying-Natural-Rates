function [s,range,eselect] = srf(m,time,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.srf">idoc model.srf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2009/03/03.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {...
   'log',true,@islogical,...
   'select',Inf,@(x) (isnumeric(x) && length(x) == 1 && isinf(x)) || iscellstr(x) || ischar(x),...
   'size','std',@(x) (ischar(x) && strcmpi(x,'std')) || isnumeric(x),...
};
options = passvalopt(default,varargin{:});

if ischar(options.select)
   options.select = charlist2cellstr(options.select);
end

% tell whether time is nper or range
if length(time) == 1 && round(time) == time && time > 0
   range = 1 : time;
else
   range = min(time) : max(time);
end
nper = length(range);

%********************************************************************
%! Function body.

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

% select shocks
if ischar(options.select) || iscellstr(options.select)
   select = findnames(options.select,m.name(m.nametype == 3));
   select = ~isnan(select);
else
   select = true([1,ne]);
end
nselect = sum(select);

shksize = nan([1,ne,nalt]);
if strcmp(options.size,'std')
   shksize = m.assign(1,end-sum(m.nametype == 3)+1:end,:);
else
   shksize(1,select,:) = options.size;
end
shksize = shksize(:,select,:);

Phi = nan([ny+nx,nselect,nper,nalt],m.precision);
[flag,index] = isnan(m,'solution');
for ialt = find(~index)
   [T,R,K,Z,H,D,U,Omega] = sspace_(m,ialt,false);
   % Call Time Domain package.
   Phi(:,:,:,ialt) = ...
      srf(T,R(:,select),K,Z,H(:,select),D,U,Omega(select,select),nper,shksize(1,:,ialt));
end

% solution not available
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

% create output database
s = struct();

% create time series for measurement and transition variables
yxid = [m.solutionid{1:2}];
elist = m.name(m.nametype == 3);
eselect = elist(select);
comment = repmat(eselect,[1,1,nalt]);
template = tseries(range,zeros([size(Phi,3),size(Phi,2),size(Phi,4)]),comment);
for i = find(imag(yxid) == 0)
   x = permute(Phi(i,:,:,:),[3,2,4,1]);
   if options.log && m.log(yxid(i))
      x = exp(x);
   end
   s.(m.name{yxid(i)}) = replace(template,x,range(1),comment);
end

% add shock time series
for i = 1 : ne
   s.(elist{i}) = template;
end
for i = 1 : nselect
   s.(eselect{i})(1,i,:) = shksize(1,i,:);
end

% add parameter database
for i = find(m.nametype == 4)
   s.(m.name{i}) = vech(m.assign(1,i,:));
end

end
% End of primary function.