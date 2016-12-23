function [options,varargin] = loglikopt_(this,range,domain,varargin)
% LOGLIKTOPT  Optional input arguments for LOGLIKT2_ and LOGLIKF_.

if strncmp(domain,'t',1)
   % Time domain options.
   default = {...
      'chkexact',false,@islogical,...
      'chkfmse',false,@islogical,...
      'deviation',false,@islogical,...
      'dtrends','auto',@(x) islogical(x) || strcmpi(x,'auto'),...
      'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x),...
      'initcond','stochastic',...
         @(x) (isstruct(x) && isfield(x,'mean') && isfield(x,'mse') && iscell(x.mean) && iscell(x.mse)) ...
         || any(strcmpi(x,{'stochastic','fixed','optimal'})),...
      'init',[],@(x) true,...
      'outoflik',{},@(x) ischar(x) || iscellstr(x),...
      'objective','mloglik',@(x) any(strcmpi(x,{'mloglik','prederr'})),...
      'objectivesample',Inf,@isnumeric,...
      'pedindonly',false,@islogical,...
      'relative',true,@islogical,...
      'std',struct(),@isstruct,...
      'tolerance',eps()^(2/3),@isnumeric,...
      'weighting',[],@isnumeric,...
   };
elseif strncmp(domain,'f',1)
   % Freq domain options.
   default = {...
      'band',[2,Inf],@(x) isnumeric(x) && length(x) == 2,...
      'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x),...
      'relative',true,@islogical,...
      'zero',false,@islogical,...
   };
else
   default = {...
      'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x),...
   };
end
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});

if strncmp(domain,'t',1)
   if ischar(options.dtrends)
      options.dtrends = ~options.deviation;
   end
end

% Out-of-lik parameters.
if strncmp(domain,'t',1)
   if isempty(options.outoflik)
      options.outoflik = [];
   else
      if ischar(options.outoflik)
         options.outoflik = charlist2cellstr(options.outoflik);
      end
      options.outoflik = options.outoflik(:)';
      offset = sum(this.nametype < 4);
      index = offset + ...
         findnames(this.name(this.nametype == 4),options.outoflik);
      isnanindex = isnan(index);
      if any(isnanindex)
         % Unknown parameter names.
         error_(68,options.outoflik(isnanindex));
      end
      options.outoflik = index;
   end
end

% Measurement variables exluded from likelihood function.
ny = sum(this.nametype == 1);
if isempty(options.exclude)
   options.exclude = false([ny,1]);
elseif islogical(options.exclude)
   options.exclude = vec(options.exclude);
   if length(options.exclude) < ny
      options.exclude(end+1:ny) = false;
   elseif length(options.exclude) > ny
      options.exclude = options.exclude(1:ny);
   end
elseif ~isempty(options.exclude) && ~islogical(options.exclude)
   tmpindex = [];
   if ischar(options.exclude)
      options.exclude = charlist2cellstr(options.exclude);
   end
   if iscellstr(options.exclude)
      tmpindex = findnames(this.name(this.nametype == 1),vech(options.exclude));
      if any(isnan(tmpindex))
         warning_(1,options.exclude(isnan(tmpindex)));
         tmpindex = tmpindex(~isnan(tmpindex));
      end
   end
   options.exclude = false([ny,1]);
   options.exclude(tmpindex) = true;
end

% Convert user-supplied std database to stdvec.
if strncmp(domain,'t',1)
   list = this.name(this.nametype == 3);
   ne = length(list);
   nper = length(range);
   options.stdvec = nan([ne,nper]);
   for i = 1 : length(list)
      stdname = sprintf('std_%s',list{i});
      if isfield(options.std,stdname)
         if istseries(options.std.(stdname))
            x = vech(rangedata(options.std.(stdname),range));
         else
            x = options.std.(stdname);
         end
         options.stdvec(i,:) = x;
      end
   end
end

end