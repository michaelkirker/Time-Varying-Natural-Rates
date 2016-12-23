function [X,Y,list,x,y] = fevd(this,time,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.fevd">idoc model.fevd</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2008/05/05. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

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

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(this);
X = nan([ny+nx,ne,nper,nalt],this.precision);
Y = nan([ny+nx,ne,nper,nalt],this.precision);

% compute FEVD for all solved parameterisations
[flag,index] = isnan(this,'solution');
for ialt = find(~index)
   [T,R,K,Z,H,D,Za,Omega] = sspace_(this,ialt,false);
   % Call Time Domain package.
   [X(:,:,:,ialt),Y(:,:,:,ialt)] = fevd(T,R,K,Z,H,D,Za,Omega,nper);
end

% solution not available
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

% write formatted variables
if nargout > 2 || iscellstr(options.select)
   ny = size(Z,1);
   nx = size(T,1);
   tmp = printid_(this);
   list = {tmp(1:ny+nx),tmp(ny+nx+1:end)};
end

% select variables
if iscellstr(options.select)
   [X,index,list,notfound] = select(X,list,options.select);
   if nargout > 1
      Y = Y(index{1},index{2},:,:);
   end
   if ~isempty(notfound)
      warning_(1,notfound);
   end
end

if nargout > 3
   % select only contemporaneous variables
   id = [this.solutionid{1:2}];
   comments = this.name(this.nametype == 3);
   comments = comments(1,:,ones([1,nalt]));
   x = struct();
   for i = find(imag(id) == 0)
      name = this.name{id(i)};
      x.(name) = tseries(range,permute(X(i,:,:,:),[3,2,4,1]),comments);
   end
   for j = find(this.nametype == 4)
      x.(this.name{j}) = vech(this.assign(1,j,:));
   end
end

if nargout > 4
   y = struct();
   for i = find(imag(id) == 0)
      name = this.name{id(i)};
      y.(name) = tseries(range,permute(Y(i,:,:,:),[3,2,4,1]),comments);
   end
   for j = find(this.nametype == 4)
      y.(this.name{j}) = vech(this.assign(1,j,:));
   end
end

end
% end of primary function
