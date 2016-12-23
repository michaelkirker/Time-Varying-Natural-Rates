function d = sourcedb_(m,range,varargin)
% SOURCEDB_  Create model-specific source database.

% The IRIS Toolbox 2009/02/20.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {...
  'ndraw',1,@(x) isnumeric(x) && length(x) == 1 && x >= 0,...
  'deviation',false,@islogical,...
  'dtrends','auto',@(x) islogical(x) || (ischar(x) && strcmpi(x,'auto')),...
  'residuals',[],@(x) isempty(x) || isa(x,'function_handle'),...
};
options = passvalopt(default,varargin{:});

if strcmp(options.dtrends,'auto')
   options.dtrends = ~options.deviation;
end

if ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

nalt = size(m.assign,3);
range = range(1) : range(end);
n1 = sum(m.nametype == 1);
n2 = sum(m.nametype == 2);
n3 = sum(m.nametype == 3);
nper = length(range);

if options.ndraw > 1 && length(nalt) > 1
   error_(47,upper(type));
end

n = n1 + n2 + n3;
nloop = max([nalt,options.ndraw]);
d = struct();

if options.deviation
   X = zeros([n,nper,nalt]);
else
   tvec = double(round(range - range(1)));
   X = zeros([n,nper,nalt]);
   X(1:n1+n2,:,:) = trendarray_(m,1:n1+n2,tvec,false,Inf);
end

if options.dtrends
   [ans,ans,D] = dtrends_(m,range,Inf);
   X(1:n1,:,:) = X(1:n1,:,:) + D;
end

X(m.log(1:n),:,:) = exp(X(m.log(1:n),:,:));

if options.ndraw > 1
   X = X(:,:,ones([1,options.ndraw]));
end

tmp = tseries();
for i = find(m.nametype <= 3)
   d.(m.name{i}) = replace(tmp,permute(X(i,:,:),[2,3,1]),range(1),m.namelabel{i});
end

% Generate random residuals if requested.
if ~isempty(options.residuals)
   d = addrand_(m,d,options.residuals,nper,nloop);
end

% Add parameters.
for i = find(m.nametype == 4)
   d.(m.name{i}) = vech(m.assign(1,i,:));
end

end
% End of primary function.

%********************************************************************
%! Subfunction addrand_(). 

function d = addrand_(m,d,fcn,nper,nloop)
   nalt = size(m.assign,3);
   ne = sum(m.nametype == 3);
   elist = m.name(m.nametype == 3);
   stdvec = m.assign(1,end-ne+1:end,:);
   for ie = 1 : ne
      x = zeros([1,nper,nloop]);
      for iloop = 1 : nloop
         if iloop <= nalt
            std = stdvec(1,ie,iloop);
         end
         x(1,:,iloop) = fcn(std,[1,nper]);
      end
      d.(elist{ie}) = replace(d.(elist{ie}),permute(x,[2,3,1]));
   end
end
% End of subfunction addrand_().