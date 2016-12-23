function d = dp2db(dpack,varargin)
% <a href="data/dp2db">DP2DB</a>  Convert datapack to database.
%
% Syntax:
%   db = dp2db(dp,...)
% Output arguments:
%   db [ struct ] Output database crated from input datapack.
% Required input arguments:
%   dp [ cell ] Input datapack.
% <a href="options.html">Optional input arguments:</a>
%   'include' [ <a href="default.html">true</a> | false ] Include initial conditions.
%   'merge' [ struct | <a href="default.html">empty</a> ] Merge output database with an existing database.

% The IRIS Toolbox 2009/03/30.
% Copyright 2007-2009 Jaromir Benes.

default = {...
  'include',true,@islogical,...
  'merge',struct(),@(x) isstruct(x) || isempty(x),...
};
options = passvalopt(default,varargin{:});

if isempty(options.merge)
   options.merge = struct();
end

dpack0 = dpack;

%********************************************************************
%! Function body.

ny = size(dpack{1},1);
nb = size(dpack{5}.U,1);
nx = size(dpack{2},1);
ne = size(dpack{3},1);
nf = nx - nb;
nper = length(dpack{4});
nalt = size(dpack{5}.U,3);
if dpack{5}.mse
   ndata = size(dpack{2},4);
else
   ndata = size(dpack{2},3);
end

try
   [yname,xname,ename,ylog,xlog,xshift] = dpmeta(dpack{5});
catch
   error('Metadata missing from the datapack. Cannot convert datapack to database.');
end

d = options.merge;

template = tseries(dpack{4},@zeros);

% measurement variables

for i = 1 : length(yname)
   if dpack{5}.mse
      % fetch only diagonal element (variance -> std error)
      % time along 3rd dimension
      y = mse2std_(permute(dpack{1}(i,i,:,:),[3,4,2,1]));
   else
      % time along 2nd dimension
      y = permute(dpack{1}(i,:,:,:),[2,3,4,1]);
   end
   if ylog(i)
      y = exp(y);
   end
   d.(yname{i}) = replace(template,y);
end

% transition variables

% transform alpha vector into xb vector
alpha2xb_();

for i = find(xshift == 0)
   if dpack{5}.mse
      % fetch only diagonal element (variance -> std error)
      % time along 3rd dimension
      x = permute(dpack{2}(i,i,:,:),[3,4,2,1]);
   else
      % time along 2nd dimension
      x = permute(dpack{2}(i,:,:,:),[2,3,4,1]);
   end
   range = dpack{4};
   % include initial condition
   if options.include
      index = strcmp(xname{i},xname) & xshift < 0;
   else
      index = strcmp(xname{i},xname) & xshift == 0;
   end
   if any(index)
      maxlag = -min(xshift(index));
      x = [nan([maxlag,size(x,2)]);x];
      t = maxlag + 1;
      for j = find(index)
         if dpack{5}.mse
            % fetch only diagonal element (variance -> std error)
            % time along 3rd dimension
            x(t+xshift(j),:,:,:) = permute(dpack{2}(j,j,1,:),[3,4,2,1]);
         else
            % time along 2nd dimension
            x(t+xshift(j),:,:,:) = permute(dpack{2}(j,1,:,:),[2,3,4,1]);
         end
      end
      range = [range(1)+(-maxlag:-1),range];
   end
   if dpack{5}.mse
      x = mse2std_(x);
   end
   if xlog(i)
      x = exp(x);
   end
   d.(xname{i}) = replace(template,x,range(1));
end

% residuals
tolmse = getrealsmall('mse');
for i = 1 : length(ename)
   if dpack{5}.mse
      % fetch only diagonal element (variance -> std error)
      % time along 3rd dimension
      e = mse2std_(permute(dpack{3}(i,i,:,:),[3,4,2,1]));
   else
      % time along 2nd dimension
      e = permute(dpack{3}(i,:,:,:),[2,3,4,1]);
   end
   d.(ename{i}) = replace(template,e);
end

% end of function body

%********************************************************************
%! Nested function alpha2xb_().

function alpha2xb_()
   try
      % Try to import Time Domain package directory.
      import('time_domain.*');
   end
   for iloop = 1 : ndata
      if iloop <= nalt
         Ui = dpack{5}.U(:,:,iloop);
         icondixi = dpack{5}.icondix(1,:,iloop);
      end
      if dpack{5}.mse
         for t = 1 : nper
            dpack{2}(nf+1:end,:,t,iloop) = Ui*dpack{2}(nf+1:end,:,t,iloop);
            dpack{2}(:,nf+1:end,t,iloop) = dpack{2}(:,nf+1:end,t,iloop)*transpose(Ui);
         end
         % first period is always initial condition
         xb = dpack{2}(nf+1:end,nf+1:end,1,iloop);
         xb(~icondixi,~icondixi) = NaN;
         dpack{2}(nf+1:end,nf+1:end,1,iloop) = xb;
         dpack{2}(:,:,:,:) = fixcov(dpack{2}); % repair negative variances
      else
         dpack{2}(nf+1:end,:,iloop) = Ui*dpack{2}(nf+1:end,:,iloop);
         % first period is always initial condition
         xb = dpack{2}(nf+1:end,1,iloop);
         xb(~icondixi) = NaN;
         dpack{2}(nf+1:end,1,iloop) = xb;
      end
   end
end
% End of nested function alpha2xb_().

end
% End of primary function.

%********************************************************************
%! Subfunction mse2std_().

function x = mse2std_(x)
   tol = getrealsmall('mse');
   x(abs(x) < tol) = 0;
   x = sqrt(x);
end
% End of subfunction mse2std_().