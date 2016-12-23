function [s,iclist,range] = icrf(m,time,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.icrf">idoc model.icrf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

default = {...
  'delog',true,@islogical,...
};
options = passvalopt(default,varargin{:});

% Tell whether time is nper or range.
if length(time) == 1 && round(time) == time && time > 0
   range = 1 : time;
else
   range = min(time) : max(time);
end
nper = length(range);

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

Phi = nan([ny+nx,nb,nper,nalt],m.precision);
[flag,index] = isnan(m,'solution');
for ialt = find(~index)
   [T,R,K,Z,H,D,U,Omega] = sspace_(m,ialt,false);
   % Call Time Domain package.   
   Phi(:,:,:,ialt) = icrf(T,[],[],Z,[],[],U,[],nper,m.linear,m.log(ny+nf+1:ny+nx));
end

% solution not available
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

% select responses to true initial conditions only
Phi = Phi(:,m.icondix,:,:);

% create output database
s = struct();

% measurement and transition variables
yxid = [m.solutionid{1:2}];
iclist = get(m,'initcond');
comment = repmat(iclist,[1,1,nalt]);
template = tseries(range,zeros([size(Phi,3),size(Phi,2),size(Phi,4)]),comment);
for i = find(imag(yxid) == 0)
   x = permute(Phi(i,:,:,:),[3,2,4,1]);
   if options.delog && m.log(yxid(i))
      x = exp(x);
   end
   s.(m.name{yxid(i)}) = replace(template,x);
end

% shocks
elist = m.name(m.nametype == 3);
for i = 1 : length(elist)
   s.(elist{i}) = template;
end

% parameters
for i = find(m.nametype == 4)
   s.(m.name{i}) = vech(m.assign(1,i,:));
end

end
% end of primary function