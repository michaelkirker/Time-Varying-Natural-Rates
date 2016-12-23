function output = resample(m,source,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.resample">idoc model.resample</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

% resample(m,dpack,ndraw,...)
% resample(m,[],range,ndraw,...)
% resample(m,dbase,range,ndraw,...)
inputformat = dataformat(source);
if strcmpi(inputformat,'dpack')
   range = source{4}(2:end);
else
   range = varargin{1};
   varargin(1) = [];
end

try
   ndraw = varargin{1};
   varargin(1) = [];
catch
   error('Input argument "ndraw" is undefined.');
end

if ~ismodel(m) || ~isnumeric(range) || ~isnumeric(ndraw) || ~iscellstr(varargin(1:2:end))
   error('Incorrect type of input argument(s).');
end

default = {...
  'deviation',false,@islogical,...
  'distribution','normal',@(x) any(strcmpi(x,{'bootstrap','normal'})),...
  'output','auto',@(x) any(strcmpi(x,{'auto','dpack','dbase'})),...
  'randomise',true,@islogical,...
  'tolerance',1e-5,@isnumeric,...
  'wild',false,@islogical,...
};
options = passvalopt(default,varargin{:});

% Determine output data format.
if strcmpi(options.output,'auto')
   if strcmpi(inputformat,'dpack')
      options.output = 'dpack';
   else
      options.output = 'dbase';
   end
end

%********************************************************************
%! Function body.

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

range = range(1) : range(end);
nper = length(range);
realsmall = getrealsmall();
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
if nalt > 1
 error_(47,'RESAMPLE');
end

[T,R,K,Z,H,D,U,Omega] = sspace_(m,1,false);
nunit = sum(abs(abs(m.eigval)-1) <= realsmall);
nstable = nb - nunit;
Tf = T(1:nf,:);
Ta = T(nf+1:end,:);
Rf = R(1:nf,:);
Ra = R(nf+1:end,:);

stdvec = vec(get(m,'stdvec'));
varvec = stdvec.^2;

% Retrieve stable part of alpha vector.
Ta2 = Ta(nunit+1:end,nunit+1:end);
Ra2 = Ra(nunit+1:end,:);
% Set unconditional mean of stable alpha.
if options.deviation
   Ea2 = zeros([nstable,1]);
else
   Ka = K(nf+1:end);
   Ea2 = (eye(nstable) - Ta(nunit+1:end,nunit+1:end)) \ Ka(nunit+1:end);
end

% Find sufficient number of iterations to reproduce covariance matrix.
% This number of iterations is used for generating pre-sample values that are cut off.
% Numerical iteration is a safer option because cov matrix may not be numerically positive definite.
if options.randomise && strcmpi(options.distribution,'normal')
   % Unconditional covariance of stable alpha.
   Ca2 = acovf(Ta(nunit+1:end,nunit+1:end),Ra(nunit+1:end,:),[],[],[],[],[],Omega,m.eigval(nunit+1:end),0);
   Sigmaa2 = Ra2*Omega*transpose(Ra2);
   Ca2_ = Sigmaa2;
   count = 0;
   while maxabs(Ca2-Ca2_) > options.tolerance
      Ca2_ = Ta2*Ca2_*transpose(Ta2) + Sigmaa2;
      count = count + 1;
   end
end

% Get data needed for bootstrap: init, alpha, resid.
if strcmp(options.distribution,'bootstrap')
   % Check that source data are available for bootstrap.
   if ~any(strcmpi(inputformat,{'dbase','dpack'}))
      error('Source database or datapack must be supplied when bootstrap is requested.');
   end
   % The values in sourceinit are transformed.
   % The values in source{2}(nf+1:end,:,:) are not transformed
   [sourceinit,naninit] = datarequest('init',m,source,range);
   sourcealpha = datarequest('alpha',m,source,range);
   sourceresid = datarequest('resid',m,source,range);
   if size(sourceinit,3) > 1 || size(sourcealpha,3) > 1 || size(sourceresid,3) > 1
      error('Multiple source data sets are not allowed in MODEL/RESAMPLE.');
   end
end

% Allocate output data.
output = {...
   nan([ny,nper,ndraw]),...
   nan([nx,nper,ndraw]),...
   nan([ne,nper,ndraw]),...
   range(1)-1:range(end),...
   meta(m,false),...
};

% Allocate initial conditions.
init = nan([nx,1,ndraw]);

if ~strcmp(options.distribution,'bootstrap')
   stdvecnper = stdvec(:,ones([1,nper]));
   if options.randomise == true
      stdveccount = stdvec(:,ones([1,count]));
   end
end

if ~options.deviation
	[ans,ans,W] = dtrends_(m,range);
end

% Distinguish between transition and measurement residuals.
rindex = any(abs(R(:,1:ne)) > 0,1);
hindex = any(abs(H(:,1:ne)) > 0,1);

for idraw = 1 : ndraw
   output{3}(:,:,idraw) = getresiduals_();
   a0 = getinitcond_();
   % transition variables
   output{2}(:,1,idraw) = T*a0 + R(:,rindex)*output{3}(rindex,1,idraw);
   if ~options.deviation
      output{2}(:,1,idraw) = output{2}(:,1,idraw) + K;
   end
   for t = 2 : nper
      output{2}(:,t,idraw) = T*output{2}(nf+1:end,t-1,idraw) + R(:,rindex)*output{3}(rindex,t,idraw);
      if ~options.deviation
         output{2}(:,t,idraw) = output{2}(:,t,idraw) + K;
      end
   end
   % measurement variables
   output{1}(:,:,idraw) = Z*output{2}(nf+1:end,:,idraw) + H(:,hindex)*output{3}(hindex,:,idraw);
   if ~options.deviation
      output{1}(:,:,idraw) = output{1}(:,:,idraw) + D(:,ones([1,nper])) + W;
   end
   % store initial condition
   init(nf+1:end,1,idraw) = a0;
end

% Add pre-sample init cond.
output{1} = [nan([ny,1,ndraw]),output{1}];
output{2} = [init,output{2}];
output{3} = [nan([ne,1,ndraw]),output{3}];

% Convert datapack to database if requested.
if strcmp(options.output,'dbase')
   output = dp2db(m,output);
end

% End of function body.

%********************************************************************
%! Nested function getresiduals_().

function e = getresiduals_()
   % Resample residuals.
   if strcmp(options.distribution,'bootstrap')
      e = nan([ne,nper]);
      if options.wild
         % Wild bootstrap.
         draw = randn([1,nper]);
         % To reproduce input sample: draw = ones([1,nper]);
         e = sourceresid.*draw(ones([1,ne]),:);
      else
         % Standard Efron bootstrap.
         % draw is uniform on [1,nper].
         draw = ceil(nper*rand([1,nper]));
         % To reproduce input sample: draw = 0 : nper-1;
         e = sourceresid(:,draw);
      end
   else
      % Draw shocks from standardised normal,
      % and scale them by std.
      e = stdvecnper.*randn([ne,nper]);
   end
end
% end of nested function getresiduals_()

%********************************************************************
%! Nested function getinitcond_().

function a0 = getinitcond_()
   % Resample initial condition for stable alpha.
   if strcmp(options.distribution,'bootstrap')
      % Bootstrap.
      if options.randomise
         if options.wild
            % Wild-bootstrap init cond for alpha from given sample init cond.
            a0 = [...
               sourceinit(1:nunit,1);...
               Ea2 + randn()*(sourceinit(nunit+1:end,1) - Ea2);...
            ];
         else
            % Bootstrap init cond for alpha from sample.
            a0 = sourcealpha(:,ceil(nper*rand()));
         end
      else
         % Fix init cond to given pre-sample init cond.
         a0 = sourceinit;
      end
   else
      % Gaussian Monte Carlo.
      % Randomise initial condition by iterating Lyapunov equation.
      if options.randomise
         e = stdveccount.*randn([ne,count]);
         a20 = zeros([nstable,1]);
         for i = 1 : count
            a20 = Ta2*a20 + Ra2*e(:,i);
         end
         a0 = [...
            zeros([nunit,1]);...
            Ea2 + a20;...
         ];
      else
         % Fix init cond to asymptotic mean.
         a0 = [...
            zeros([nunit,1]);...
            Ea2;...
         ];
      end
   end
end
% End of nested function getinitcond_().

end
% End of primary function.