function varargout = filter_(x,dates,filtersetup,defaultlambda,varargin)
% Called from within tsereis/bwf, tseries/hpf, tseries/llf.

% The IRIS Toolbox 2009/04/23.
% Copyright (c) 2007-2009 Jaromir Benes.

freq = datfreq(x.start);
default = {
   'drift',0,@(x) isnumeric(x) && length(x) == 1,...
   'gap',[],@(x) isempty(x) || istseries(x),...
   'growth',[],@(x) isempty(x) || istseries(x),...
   'lambda',[],@(x) isnumeric(x) && length(x) <= 1,...
   'level',[],@(x) isempty(x) || istseries(x),...
   'log',false,@islogical,...
   'swap',false,@islogical,...
   'forecast',[],@(x) isnumeric(x) && length(x) <= 1,...
};
options = passvalopt(default,varargin{1:end});

%********************************************************************
%! Function body.

% default lambda
if isempty(options.lambda)
   if freq == 0
      error('No default lambda for time series with indeterminate frequency.');
   else
      options.lambda = defaultlambda(freq);
   end
end

if any(options.lambda <= 0)
   error('Smoothing parameter must be a positive number.');
end

options.lambda = vech(options.lambda);
nlambda = length(options.lambda);
options.drift = vech(options.drift);
ndrift = length(options.drift);

% Convert ND to 2D.

% data
sizeofx = size(x.data);
x.data = x.data(:,:);
nx = size(x.data,2);
xfirst = x.start;
xlast = xfirst + size(x.data,1) - 1;

% Level tunes.
if ~isempty(options.level) && istseries(options.level)
   options.level.data = options.level.data(:,:);
   nl = size(options.level.data,2);
   lfirst = options.level.start;
   llast = lfirst + size(options.level.data,1) - 1;
else
   % Convert empty or non-tseries objects to empty numeric.
   options.level = [];
   lfirst = [];
   llast = [];
   nl = 0;
end

% Growth tunes.
if ~isempty(options.growth) && istseries(options.growth)
   options.growth.data = options.growth.data(:,:);
   ng = size(options.growth.data,2);
   gfirst = options.growth.start;
   glast = gfirst + size(options.growth.data,1) - 1;
else
   % Convert empty or non-tseries objects to empty numeric.
   options.growth = [];
   gfirst = [];
   glast = [];
   ng = 0;
end

if options.log
   x.data = log(x.data);
   if ~isempty(options.level)
      options.level.data = log(options.level.data);
   end
   if ~isempty(options.growth)  
      options.growth.data = log(options.growth.data);
   end
end

% Determine filtering range.
if any(isinf(dates))
   ffirst = xfirst;
   flast = xlast;
else
   ffirst = min(dates);
   flast = max(dates);
end
ffirst = min([ffirst,lfirst,gfirst-1]);
flast = max([flast,llast,glast]);
nfilter = flast - ffirst + 1;

nloop = max([nx,nlambda,ndrift,nl,ng]);
if nx == 1 & nloop > 1
   sizeofx(2) = nloop;
end

tnd = nan([nfilter,nloop]);
gap = nan([nfilter,nloop]);

for iloop = 1 : nloop
  
   if iloop <= nlambda
      lambdai = options.lambda(iloop);
   end
   if iloop <= ndrift
      drifti = options.drift(iloop);
   end

   % Get x and add pre-sample and post-sample NaNs.
   if iloop <= nx
      xi = getdata_(x,ffirst:flast,iloop);
      if ~any(isinf(dates))
         % use only user-specified dates
         index = false([1,nfilter]);
         index(round(dates - ffirst + 1)) = true;
         xi(~index) = NaN;
      end
   end

   [X,B] = filtersetup(xi,nfilter,lambdai,drifti);
   
   % Add level constraints.
   if ~isempty(options.level)
      if iloop <= nl
         % Add pre-sample and post-sample NaNs.
         leveli = [nan([lfirst-ffirst,1]);options.level.data(:,iloop);nan([flast-llast,1])];
      end
      index = ~isnan(leveli);
      if any(index)
         X = [X;leveli(index)];
         for j = vech(find(index))
            B(end+1,j) = 1;
            B(j,end+1) = 1;
         end
      end
   end

   % Add growth constraints.
   if ~isempty(options.growth)
      if iloop <= ng
         % Add pre-sample and post-sample NaNs.
         growthi = [nan([gfirst-ffirst,1]);options.growth.data(:,iloop);nan([flast-glast,1])];
      end
      index = ~isnan(growthi);
      if any(index)
         X = [X;growthi(index)];
         for j = vech(find(index))
            B(end+1,[j-1,j]) = [-1,1];
            B([j-1,j],end+1) = [-1;1];
         end
      end
   end

   ans = B \ X;
   tnd(:,iloop) = ans(1:nfilter);
   gap(:,iloop) = xi - tnd(:,iloop);

end % of for

if options.log
   tnd = exp(tnd);
   gap = exp(gap);
end

varargout{1} = x;
varargout{1}.start = ffirst;
varargout{1}.data = reshape(tnd,[nfilter,sizeofx(2:end)]);
varargout{1} = cut_(varargout{1});

varargout{2} = x;
varargout{2}.start = ffirst;
varargout{2}.data = reshape(gap,[nfilter,sizeofx(2:end)]);
varargout{2} = cut_(varargout{2});

% Swap output arguments upon request.
if options.swap
   varargout([1,2]) = varargout([2,1]);
end

end
% End of primary function.