function [pstar,obj,Grad,Hess,m,se2,F,pe,delta,void1,void2,pred,smooth] = estimate(m,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.estimate">idoc model.estimate</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/14.
% Copyright 2007-2009 Jaromir Benes.

% Syntax:
%    [pstar,obj,grad,hess,m,se2,F,pe,A,Pa,setup,pred,smooth] = estimate(m,dpack,p,...) 
%    [pstar,obj,grad,hess,m,se2,F,pe,A,Pa,setup,pred,smooth] = estimate(m,dbase,range,p,...)
% Output arguments:
%    pstar [ struct ] Database with point estimates of requested parameters.
%    mloglik [ numeric ] Value of objective function.
%    grad [ numeric ] Gradient at optimum.
%    hess [ numeric ] Hessian at optimum.
% Required input arguments:
%    m [ model ] Model.
%    p [ struct ] Database of optimised parameters entered as 1x3 or 1x4 cell arrays: {init,lo,hi} or {init,lo,hi,prior_distrib}.
%    dpack [ cell ] Input datapack.
%    dbase [ cell ] Input database.
%    range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%    'exclude' [ cellstr | <a href="">empty</a> ] List of measurement variables to be excluded from likelihood function (treated as deterministic).
%    'maxiter' [ numeric | <a href="default.html">2000</a> ] Maximum number of iterations allowed.
%    'objective' [ <a href="default.html">'mloglik'</a> | 'prederr' | function_handle ] Objective function to be minimised.
%    'objectivesample' [ <a href="default.html">Inf</a> | numeric ] Sub-sample on which the objective function is to be computed.
%    'output' [ <a href="default.html">'auto'</a> | 'dbase' | 'dpack' ] Format of output data.
%    'penalty' [ numeric | <a href="default.html">0</a> ] Regularise the likelihood function with a quadratic penalty function.
%    'refresh' [ <a href="default.html">true</a> | false ] Refresh dynamic links for each parameter set.
%    'relative' [ <a href="default.html">true</a> | false ] Scale MSE matrices by estimated variance factor.
%    'solve' [ <a href="default.html">true</a> | false ] Compute solution for each parameter set.
%    'sstate' [ true | <a href="default.html">false</a> | function_handle ] Function to compute steady state.
%    'tolfun' [ numeric | <a href="default.html">1e-8</a> ] Termination tolerance on log-likehood function.
%    'tolx' [ numeric | <a href="default.html">1e-8</a> ] Termination tolerance on optimised parameters.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

% Get array of measurement variables.
[data,range,varargin,outputformat] = loglikdata_(m,data,varargin{:});

if ~ismodel(m) || ~isstruct(varargin{1})
   error('Incorrect type of input argument(s).');
end

% Database of parameters to be estimated.
D = varargin{1};
varargin(1) = [];

default = {...
   'domain','time',@(x) any(strncmpi(x,{'t','f'},1)),...
   'epspower',1/2,@isnumeric,...
   'logprior',false,@islogical,...
   'maxiter',500,@(x) isnumericscalar(x) && x >= 0,...
   'maxfunevals',2000,@(x) isnumericscalar(x) && x > 0,...
   'nosolution','error',@(x) any(strcmpi(x,{'error','penalty'})),...
   'penalty',0,@(x) (isnumeric(x) && x >= 0) || isa(x,'function_handle'),...
   'refresh',true,@islogical,...
   'solve',true,@islogical,...
   'sstate',false,@(x) islogical(x) || isempty(x) || isa(x,'function_handle'),...
   'tolfun',1e-6,@(x) isnumeric(x) && x > 0,...
   'tolx',1e-6,@(x) isnumeric(x) && x > 0,...
   'zero',false,@islogical,...
};
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});

loglikoptions = loglikopt_(m,range,options.domain,varargin{:});

if strncmpi(options.domain,'t',1)
   options.domain = 1;
   % Time domain likelihood.
   loglik_ = @(x) loglikt2_(x,data,range,[],loglikoptions);
else
   options.domain = 2;
   % Frequency domain likelihood.
   [I,freq,delta] = fourierdata_(m,data,loglikoptions);
   loglik_ = @(x) loglikf_(x,I,freq,delta,loglikoptions);
end

void1 = []; % Void arguments for bkw compatibility.
void2 = []; % Void arguments for bkw compatibility.

%********************************************************************
%! Function body.

if isempty(m.refresh)
   options.refresh = false;
end

ndata = size(data,3);

% Mmultiple parameterisations not allowed.
if nalt > 1 || ndata > 1
   error_(47,'MAXLOGLIK');
end

% Retrieve names of optimised parameters,
% initial values, lower & upper bounds, and prior distributions.
% Set parameters in m to starting values.
[m,name,p0,pl,pu,prior,pindex,notfound,invalidbounds,highinit,lowinit] = ...
   optimparams_(m,D);

if ~isempty(notfound)
   warning_(31,notfound);
end

if ~isempty(invalidbounds)
   warning_(46,invalidbounds);
end

if ~isempty(highinit)
   warning_(49,highinit);
end

if ~isempty(lowinit)
   warning_(50,lowinit);
end

% No parameters to be optimised.
if isempty(pindex)
   warning_(48);
   return
end

% Number of optimised parameters.
np = length(pindex);

priorindex = cellfun(@(x) isa(x,'function_handle'),prior);
isprior = any(priorindex);

weights = zeros(size(p0));
tmpindex = cellfun(@(x) isnumeric(x) && ~isempty(x),prior);
weights(tmpindex) = cell2mat(prior(tmpindex));
if isa(options.penalty,'function_handle')
   for i = 1 : np
      weights(i) = weights(i)*options.penalty(p0(i));
   end
else
   weights = weights*options.penalty;
end
weights(weights < 0) = 0;
penaltyindex = weights > 0;
ispenalty = any(penaltyindex);

%{
% normalise prior mean (=starting value) by std deviation = mean/2
% so that the implied t-ratio is 2 for penalty = 1
if options.penalty > 0
   ip02 = weights ./ ((p0/2).^2);   
end%if
%}

% Database P used only if steady state is requested.
if isa(options.sstate,'function_handle')
   P = struct();
   for i = find(m.nametype == 4)
      P.(m.name{i}) = m.assign(i);
   end
end

optimtbx = optimset(...
   'display','iter',...
   'maxiter',options.maxiter,...
   'maxfunevals',options.maxfunevals,...
   'GradObj','off',...
   'Hessian','off',...
   'LargeScale','off',...
   'tolfun',options.tolfun,...
   'tolx',options.tolx);

Grad = {zeros([1,np]),zeros([1,np])};
Hess = {zeros(np),zeros(np)};
ps0 = p0;
obj0 = realmax()*eps();

% Call Optimization Tbx.
if all(isinf(pl)) && all(isinf(pu))
   [pstar,obj,EXITFLAG,OUTPUT,Grad{1}(:,:),Hess{1}(:,:)] = fminunc(@objfcn1_,p0,optimtbx);
else
   [pstar,obj,EXITFLAG,OUTPUT,Lambda,Grad{1},Hess{1}] = fmincon(@objfcn1_,p0,[],[],[],[],pl,pu,[],optimtbx);
end

% Compute prior and penalty contributions to gradient and hessian.
if isprior
   [ans,gradprior,hessprior] = prior_(pstar);
   Grad{2} = Grad{2} + gradprior;
   Hess{2} = Hess{2} + hessprior;
end
if ispenalty
   [ans,gradpenal,hesspenal] = penalty_(pstar);
   Grad{2} = Grad{2} + gradpenal;
   Hess{2} = Hess{2} + hesspenal;
end

% Assign estimated parameters,
% and handle sstate and solve.
if nargout > 4
   [m,npath] = updatemodel_(m,pstar,pindex,options);
end

%********************************************************************
%! Post-mortem.

if options.domain == 1 && nargout > 4
   if nargout > 12
      % Smoothing requested.
      [obj1,se2,F,pe,delta,ans,ans,pred,smooth] = loglik_(m);
   elseif nargout > 11
      % No smoothing requested.
      [obj1,se2,F,pe,delta,ans,ans,pred] = loglik_(m);
   else
      % Nor smoothing neither prediction requested.
      [obj1,se2,F,pe,delta] = loglik_(m);
   end
   % Create prediction error array and dbase.
   pe = pestruct_(m,pe,range);
   % Scale stdevs by estimated factor, and assign out-of-lik params. No
   % need to recompute sstate or solution.
   m = stdscale(m,sqrt(se2));
   m.assign(1,loglikoptions.outoflik) = vech(delta);
   m = refresh(m);
   % Create database of out-of-lik parameter estimates.
   tmpdelta = delta;
   delta = struct();
   if ~isempty(tmpdelta)
      tmpname = m.name(loglikoptions.outoflik);
      for i = 1 : length(tmpname)
         delta.(tmpname{i}) = vech(tmpdelta(1,i,:));
      end
   end      
   if strcmpi(outputformat,'dbase')
     % Convert dpack to dbase.
     if nargout > 11
         pred.mean = dp2db(m,pred.mean);
         pred.std = dp2db(m,pred.mse);
         pred = rmfield(pred,'mse');
         if nargout > 12
            smooth.mean = dp2db(m,smooth.mean);
            smooth.std = dp2db(m,smooth.mse);
            smooth = rmfield(smooth,'mse');
         end
      end
   end
else
   [obj,se2] = loglik_(m);
   % Scale std errors by estimated factor.
   m = stdscale(m,sqrt(se2));
   m = refresh(m);
end

pstar = cell2struct(num2cell(pstar),name,2);

% End of function body.

%********************************************************************
%! Nested function objfcn1_().
% Optimisation tbx computes gradient and hessian numerically.
   function obj = objfcn1_(p)
      % Assign parameters,
      % recompute steady state if requested,
      % solve model if requested,
      % refresh links if requested.
      [m,npath] = updatemodel_(m,p,pindex,options);
      if npath ~= 1
         if strcmp(options.nosolution,'error')
            failed(m,npath,'estimate');
         else
            obj = obj0 + 10*abs(obj0);
         end
      end
      obj = loglik_(m);
      if isprior
         mlogprior = zeros(size(p));
         mlogprior(priorindex) = -log(cellfun(@feval,prior(priorindex),num2cell(p(priorindex))));
         obj = obj + sum(mlogprior);
      end
      if ispenalty
         objpenal = penalty_(p);
         obj = obj + objpenal;
      end
      ps0 = p;
      obj0 = obj;
   end
% End of nested function objfcn1_().

%********************************************************************
%! Nested function objfcn2_().
% Use model/diffloglik to compute asymptotic gradient and Hessian.
%{
function [obj,grad,hess] = objfcn2_(ps)
   npath = assign_(ps);
   if npath ~= 1
      if strcmp(options.nosolution,'error')
         npatherror_(npath,ps,ps0);
      else
         obj = obj0 + abs(obj0);
      end
   end
   [obj,grad,hess] = diffloglik_(m,data,range,name,pindex,optioncelllarge{:});
   if isprior
      [objprior,gradprior,hessprior] = prior_(ps);
      obj = obj + objprior;
      grad = grad + gradprior;
      hess = hess + hessprior;
   elseif options.penalty > 0
      [objpenal,gradpenal,hesspenal] = penalty_(ps);
      obj = obj + objpenal;
      grad = grad + gradpenal;
      hess = hess + hesspenal;
   end
   ps0 = ps;
   obj0 = obj;
end
% End of nested function objfcn2_().
%}

%********************************************************************
%! Nested function prior_().
% Compute pdf, gradient and hessian for general prior distributions.

function [objprior,gradprior,hessprior] = prior_(p)
   tmp = p(priorindex);
      step = max([abs(tmp);ones(size(tmp))],[],1)*eps()^(1/3);
      tmpplus = tmp + step;
      tmpminus = tmp - step;    
      mlogprior = -log(cellfun(@feval,prior(priorindex),num2cell(tmp)));
      mlogpriorplus = -log(cellfun(@feval,prior(priorindex),num2cell(tmpplus)));
      mlogpriorminus = -log(cellfun(@feval,prior(priorindex),num2cell(tmpminus)));
      twosteps = tmpplus - tmpminus;
   objprior = sum(mlogprior);
   if nargout > 1
      gradprior = zeros(size(p));
      hessprior = zeros(np);
      gradprior(priorindex) = (mlogpriorplus - mlogpriorminus) ./ twosteps;
      hessprior(priorindex) = (mlogpriorplus - 2*mlogprior + mlogpriorminus) ./ (twosteps.^2);
      hessprior = spdiags(hessprior(:),0,np,np);  
   end
end
% End of nested function prior_().

%********************************************************************
%! Nested function penalty_().

function [objpenal,gradpenal,hesspenal] = penalty_(p)
   objpenal = zeros(size(p));
   objpenal(penaltyindex) = ...
      sum(((p(penaltyindex) - p0(penaltyindex)).^2).*weights((penaltyindex)));
   objpenal = sum(objpenal);
   if nargout > 1
      gradpenal = zeros(size(p));
      hesspenal = zeros(size(p));
      gradpenal(penaltyindex) = 2*(p(penaltyindex) - p0(penaltyindex)).*weights(penaltyindex);
      hesspenal(penaltyindex) = 2*weights(penaltyindex);
      hesspenal = spdiags(hesspenal(:),0,np,np);
   end
end
% End of nested function penalty_().

%{
%********************************************************************
%! Nested function npatherror_().
   function npatherror_(npath,ps,ps0)
      if npath == 0
         msg = 'no stable solution';
      elseif npath == Inf
         msg = 'multiple stable solutions';
      elseif imag(npath) ~= 0
         msg = 'complex derivatives';
      elseif isnan(npath)
         msg = 'NaN derivatives';
      elseif npath == -1
         msg = 'singularity in the state-space form';
      end
      failed = m;
      error([...
         'MAXLOGLIK failed because parameters have reached a region with %s.\n',...
         'Type <a href="matlab: x = estimate(model);">x = estimate(model);</a> to get the model object that failed to solve.',...
         ],msg);
   end
% end of nested function npatherror_()
%}

end
% End of primary function.