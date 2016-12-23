function [w,data,Rr,count] = estimate_(w,varargin)
%
% <a href="matlab: edit rvar/rvar">RVAR</a>  Estimate reduced-form VAR model.
%
% Syntax:
%   [w,data,Rr] = rvar(y,...)
%   [w,data,Rr] = rvar(x,range,...)
%   [w,data,Rr] = rvar(d,list,range,...)
% Output arguments:
%   w [ rvar ] Estimated RVAR model.
%   data [ tseries ] Multivariate time series with VAR variables and residuals.
%   Rr [ numeric ] Linear constraints in matrix form: beta=r+R*gamma, Rr = [R,r].
% Required input arguments for syntax
%   y [ numeric ] Input data including initial condition.
%   x [ tseries ] Input data.
%   range [ numeric ] Time range to be explained (not to include dates used as initial condition).
%   d [ struct ] Input database.
%   list [ cellstr | char ] List of time series.
% <a href="options.html">Optional input arguments:</a>
%   'order' [ numeric | <a href="default.html">1</a> ] Order of VAR.
%   'polyorder' [ numeric | <a href="default.html">Inf</a> ] Order of polynomially distributed lags.
%   'cointeg' [ numeric | <a href="default.html">empty</a> ] Matrix of conintegrating vectors.
%   'constraint' [ char | numeric | <a href="default.html">empty</a> ] Linear constraints on parameters in character string or matrix form.
%   'comment' [ anything | <a href="default.html">empty</a> ] User comments.
%   'constant' [ <a href="default.html">true</a> | false ] Include constant.
%   'maxiter' [ numeric | <a href="default.html">10</a> ] Maximum number of iteration for GLS.
%   'mean' [ numeric | <a href="default.html">empty</a> ] Imposed mean of VAR process.
%   'tolerance' [ numeric | <a href="default.html">1e-5</a> ] Tolerance criterion for GLS.

% The IRIS Toolbox 2008/10/25.
% Copyright (c) 2007-2008 Jaromir Benes.

% Find position of first option.
tmpindex = find(cellfun(@ischar,varargin),1);
if isempty(tmpindex)
   inputdata = varargin;
   varargin(:) = [];
else
   inputdata = varargin(1:tmpindex-1);
   varargin(1:tmpindex-1) = [];
end

default = {
   'order',1,...
   'cointeg',[],...
   'constraint','',...
   'constraints','',...
   'comment','',...
   'const',[],...
   'constant',true,...
   'covparameters',false,...
   'dummyobs',[],...
   'maxiter',10,...
   'mean',[],...
   'tolerance',1e-5,...
   'ylist',{},...
   'elist',{},...
};
options = passopt(default,varargin{:});

% Get data including pre-sample initial conditions.
% Range containes pre-sample.
[y,range] = getdata(options.order,inputdata{:});

% Both 'constraint' and 'contraints' allowed for bkw cmp.
if ~isempty(options.constraint)
   options.constraints = options.constraint;
end

% Both 'const' and 'constant' allowed for bkw cmp.
if ~isempty(options.const)
   options.constant = options.const;
end

options.mean = vec(options.mean);

%********************************************************************
%! Function body.

try
   import('time_domain.*');
end

p = options.order;
[ny,ans,ndata] = size(y);
[sample,flag] = getsample(y);
% within-sample NaNs
if ~flag
   error_(9);
end 
% effective estimation sample shorter than user-specified
if any(~sample)
   aux = dat2str(range(~sample));
   warning_(4,sprintf(' %s',aux{:}));
end

% insufficient number of observations
if sum(sample) < ny || sum(sample)-p <= 0
   error_(10);
end

y = y(:,sample,:);
range = range(sample); % range includes initial conditions
nper = sum(sample) - p;
if ~isempty(options.mean)
   ymean = options.mean(:,ones([1,size(y,2)]));
   for idata = 1 : ndata
      y(:,:,idata) = y(:,:,idata) - ymean;
   end
   options.constant = false;
end

% Arrange data on LHS and RHS.
[y0,y1,k0,g1] = stackdata(y,options);
tmpsize = size(y0);
ny = tmpsize(1);
nper = tmpsize(2);
ng = size(g1,1);
nk = size(k0,1);

% Read parameter restrictions Rr = [R,R] so that beta = R*gamma + r.
w = restrict1_(w,ny,nk,ng,options);

% Get number of hyperparameters.
if isempty(w.Rr)
   w.nhyper = nk+p*ny+ng;
else
   w.nhyper = size(w.Rr,2) - 1;
end

% Number of priors.
nprior = size(options.dummyobs,3);

nloop = max([ndata,nprior]);

% Estimate rVAR parameters.
p = options.order;
w.A = nan([ny,ny*p,nloop]);
w.K = nan([ny,nloop]);
w.Omega = nan([ny,ny,nloop]);
w.Sigma = [];
resid = nan([ny,p+nper,nloop]);
count = zeros([1,nloop]);

% Do not pass options.dummyobs into glsq_().
dummyobs = options.dummyobs;
options = rmfield(options,'dummyobs');

% Main loop.
use = struct();
for iloop = 1 : nloop   
   if iloop <= ndata
      use.y0 = y0(:,:,iloop);
      use.y1 = y1(:,:,iloop);
      use.g1 = g1(:,:,iloop);
   end
   if isempty(dummyobs)
      use.dummyobs = [];
   elseif iloop <= nprior
      py0 = dummyobs(1:ny,:,iloop);
      pk0 = dummyobs(ny+1,:,iloop);
      py1 = dummyobs(ny+1+(1:ny*p),:,iloop);
      pg1 = dummyobs(end-ny+1:end,:,iloop);
      pk0 = pk0(1:nk,:);
      pg1 = pg1(1:ng,:);
      if ng > 0
         % Reduce number of lags
         % because VAR will be estimated as VECM in first differences.
         py1 = py1(1:end-ny,:);
      end
      use.dummyobs = [py0;pk0;py1;pg1];
   end
   [w.A(:,:,iloop),w.K(:,iloop),w.Omega(:,:,iloop),w.Sigma(:,:,iloop),resid(:,p+1:end,iloop),count(1,iloop)] = glsq_(w,use.y0,use.y1,k0,use.g1,use.dummyobs,options);
end

% Convert data into time series.
data = tseries(range,[permute(y,[2,1,3]),permute(resid,[2,1,3])]);

% populate VAR characteristics
% sample includes explained obervations only
w.sample = range(p+1:end);
for iloop = 1 : nloop
   % back out VAR constant given mean restriction
   if ~isempty(options.mean)
      w.K(:,iloop) = sum(var2poly(w.A(:,:,iloop)),3)*options.mean;
   end
   % information criteria
   w.aic(iloop) = log(det(w.Omega(:,:,iloop))) + 2/nper * w.nhyper;
   w.sbc(iloop) = log(det(w.Omega(:,:,iloop))) + log(nper)/nper * w.nhyper;
end
w.comment = options.comment;

% Schur decomposition and eigenvalues.
w = schur_(w);

if nargout > 2
   Rr = w.Rr;
end

end
% End of primary function.
