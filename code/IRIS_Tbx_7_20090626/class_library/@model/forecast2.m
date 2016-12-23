function [func,fcon,Pi] = forecast(m,init,range,j,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.forecast">idoc model.forecast</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse the The IRIS Toolbox documentation found in the Contents pane.

% The IRIS Toolbox 2008/05/05.
% Copyright 2007-2008 Jaromir Benes.

default = {...
  'anticipate',true,@islogical,...
  'deviation',false,@islogical,...
  'initcond','data',@(x) any(strcmp(lower(x),{'data','fixed'})) || isnumeric(x),...
  'output','auto',@(x) any(strcmpi(lower(x),{'auto','dpack','dbase'})),...
  'precision',m.precision,@(x) any(strcmpi(lower(x),{'double','single'})),...
  'std',[],@(x) isempty(x) || isstruct(x),...
};
options = passvalopt(default,varargin{:});

if isempty(j)
   j = struct();
end

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

range = range(1) : range(end);
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
nper = length(range);

nanticipate = length(options.anticipate(:));
ndeviation = length(options.deviation(:));

% Determine output data format.
if strcmpi(options.output,'auto')
	options.output = dataformat(init);
end

% Check that datapack is consistent with model struture.
if isdpack_(init) && ~chkdpack_(m,init)
   error_(66);
end

% Get init cond (mean, MSE) for alpha vector.
% Initmse is [] if MSE is not available.
[initmean,naninit,initmse] = datarequest('init',m,init,range);
if ~isempty(naninit)
   error_(25,naninit);
end
ninit = size(initmean,3);

% convert cond into array with measurement variables
% and structural shocks
shock = datarequest('e',m,j,range);
cond = datarequest('y',m,j,range);
ncond = size(cond,3);
nshock = size(shock,3);

% get std deviations of shocks
stdvec = stdvec_(m,options.std,range);
nstd = size(stdvec,3);

% total number of cycles
nloop = max([nalt,nanticipate,ndeviation,ninit,ncond,nshock,nstd]);

% pre-allocate output datapack
nan_ = @(dim) nan([dim,1+nper,nloop],options.precision);
func = struct();
func.mean = {nan_(ny),nan_(nx),nan([ne,1+nper,nloop]),[range(1)-1,range],meta(m,false)};
func.mse = {nan_([ny,ny]),nan_([nx,nx]),nan_([ne,ne]),[range(1)-1,range],meta(m,true)};
if nargout > 1
   fcon = struct();
   fcon.mean = {nan_(ny),nan_(nx),nan([ne,1+nper,nloop]),[range(1)-1,range],meta(m,false)};
   fcon.mse = {nan_([ny,ny]),nan_([nx,nx]),nan_([ne,ne]),[range(1)-1,range],meta(m,true)};   
end

% Test statistic.
Pi = nan([1,nloop]);

nansolution = []; % index of NaN solutions
nanexpand = []; % index of NaN expansions

use = struct();

for iloop = 1 : nloop

   if iloop <= ndeviation
      use.deviation = options.deviation(iloop);
   end

   if iloop <= nanticipate
      use.anticipate = options.anticipate(iloop);
   end

   if iloop <= ncond
      % Measurement conditions including detereministic trends.
      use.conddet = cond(:,:,iloop);
      use.condindex = ~isnan(use.conddet);
      use.lastcond = max([0,find(any(use.condindex,1),1,'last')]); % last imposed tune
      use.condindex = use.condindex(:,1:use.lastcond);
      use.condindex = vech(use.condindex);
   end

   if iloop <= nalt
      % model solution
      [use.T,use.R,use.K,use.Z,use.H,use.D,use.U] = sspace_(m,iloop,true);
      % matrices for forward expansion
      use.expand = cell(size(m.expand));
      for i = 1 : length(m.expand)
         use.expand{i} = m.expand{i}(:,:,iloop);
      end
      % deterministic trends
      if ~use.deviation
         [ans,ans,use.W] = dtrends_(m,range,iloop);
      end
   end

   if any(any(isnan(use.T)))
      nansolution(end+1) = iloop;
      continue
   end

   if any(any(isnan(use.expand{1})))
      nanexpand(end+1) = iloop;
      continue
   end

   if iloop <= nalt || iloop <= nstd
      use.stdvec = stdvec(:,:,iloop);
   end

   if iloop <= nalt || iloop <= ncond
      % Correct condition for deterministic trends.
      if use.deviation
         use.cond = use.conddet;
      else
         use.cond = use.conddet - use.W;   
      end     
   end

   if iloop <= ninit
      % Init condition for mean and MSE.
      use.initmean = initmean(:,1,iloop);
      if ~isempty(initmse) && ~strcmpi(options.initcond,'fixed')
         use.initmse = initmse(:,:,iloop); 
      else
         use.initmse = sparse(zeros(length(use.initmean)));
      end
   end

   if iloop <= nshock
      use.shock = shock(:,:,iloop);
      use.lastshock = max([0,find(any(use.shock ~= 0),1,'last')]); % last imposed shock
   end

   % furthest anticipated shock needed
   if use.anticipate
      use.last = max([use.lastshock,use.lastcond]);   
   else
      use.last = 0;
   end
 
   if ne ~= 0
      if use.last > size(use.R,2)/ne;
         [use.R,use.expand{5}] = expand_(use.R,use.last-1,use.expand{1:5});
      end
   end

   % Call general state-space forecast.
   if nargout == 1
      tmpunc = ...
         forecast(use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec,...
         use.initmean,use.initmse,use.shock,use.cond,use.anticipate,use.deviation);
   else
      [tmpunc,tmpcon,Pi(iloop)] = ...
         forecast(use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec,...
         use.initmean,use.initmse,use.shock,use.cond,use.anticipate,use.deviation);
   end
         
   for i = 1 : 3
      func.mean{i}(:,:,iloop) = tmpunc.mean{i};
      func.mse{i}(:,:,:,iloop) = tmpunc.mse{i};
      if nargout > 1
         fcon.mse{i}(:,:,:,iloop) = tmpcon.mse{i};
         fcon.mse{i}(:,:,:,iloop) = tmpcon.mse{i};      
      end
   end
   
   % Add dtrends to measuremenet variables.
   if ~use.deviation
      func.mean{1}(:,2:end,iloop) = func.mean{1}(:,2:end,iloop) + use.W;
      if nargout > 1
         fcon.mean{1}(:,2:end,iloop) = fcon.mean{1}(:,2:end,iloop) + use.W;
      end
   end      

end
% End of the main for-loop.

if strcmp(options.output,'dbase')
   func.mean = dp2db(func.mean);
   func.std = dp2db(func.mse);
   func = rmfield(func,'mse');
   if nargout > 1
      fcon.mean = dp2db(fcon.mean);
      fcon.std = dp2db(fcon.mse);
      fcon = rmfield(fcon,'mse');
   end
end

% expansion not avaiable
if ~isempty(nansolution)
   warning_(44,sprintf(' #%g',nansolution));
end

% expansion not avaiable
if ~isempty(nanexpand)
   warning_(45,sprintf(' #%g',nanexpand));
end

end
% end of primary function