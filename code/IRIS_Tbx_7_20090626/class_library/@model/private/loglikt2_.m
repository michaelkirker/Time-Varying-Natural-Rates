function [obj,se2,F,pe,delta,void1,pedindout,pred,smooth] = loglikt2_(m,data,range,pedind,options)
% LOGLIKT2_  Version 2 of Kalman filter to evaluate likelihood function in
% time domain.

% The IRIS Toolbox 2009/04/09.
% Copyright (c) 2007-2008 Jaromir Benes.

% TODO: Convert options.std to options.stdvec before it enters loglikt_.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
void1 = []; % Void argument for bkw compatibility.
ispedindin = ~isempty(pedind);
ispedindout = nargout > 6;
dopredict = ~options.pedindonly && nargout > 7;
dosmooth = ~options.pedindonly && nargout > 8;

s = struct();

if ~isnumeric(data)
   error('Incorrect type of input argument(s).');
end

if length(options.weighting) == 1
   options.weighting = options.weighting(ones([1,ny]));
end

if any(size(options.weighting) == 1)
   options.weighting = sparse(diag(options.weighting));
end

% Use this function to make covariance matrices truly symmetric.
symmet_ = @(X) (X + X')/2;
   
%********************************************************************
%! Function body.

realsmall = getrealsmall();

% Out-of-lik params cannot be used with ~options.dtrends.
npout = length(options.outoflik);
if npout > 0 && ~options.dtrends
   error_(64);
end

% Source data are always numeric arrays without initial condition.
% Add pre-sample initial condition.
ndata = size(data,3);
data = [nan([ny,1,ndata]),data];
range = range(1)-1 : range(end);
nper = length(range);

% Add pre-sample to options.stdvec.
options.stdvec = [nan([ne,1]),options.stdvec];

% Sample used to compute objective function and out-of-lik parameters.
if any(isinf(options.objectivesample))
   options.objectivesample = 2 : nper;
else
   tmpstart = round(options.objectivesample(1) - range(1) + 1);
   if tmpstart < 2
      tmpstart = 2;
   end
   tmpend = round(options.objectivesample(end) - range(1) + 1);
   if tmpend > nper
      tmpend = nper;
   end
   options.objectivesample = tmpstart : tmpend;
end

% Total number of cycles.
nloop = max([ndata,nalt]);

% Pre-allocation.
obj = nan([1,nloop]);
se2 = nan([1,nloop]);
F = cell([1,2]);
F(:) = {nan([ny,ny,nper-1,nloop])};
pe = nan([ny,nper-1,nloop]);
delta = nan([1,npout,nloop]);
nandata = false([1,nloop]);
exact = nan([1,nloop]);
pedindlist = {'Pa0','Pa1','F','Fi','G0','G1','ZtFi'};
if ispedindout
   pedindout = cell2struct(cell(size(pedindlist)),pedindlist,2);
end

if dopredict
   me = meta(m,false);
   memse = me;
   memse.mse = true;
   pred.mean = {nan([ny,nper,nloop]),nan([nx,nper,nloop]),nan([ne,nper,nloop]),range,me};
   pred.mse = {nan([ny,ny,nper,nloop]),nan([nx,nx,nper,nloop]),nan([ne,ne,nper,nloop]),range,memse};
   if dosmooth
      smooth.mean = {nan([ny,nper,nloop]),nan([nx,nper,nloop]),nan([ne,nper,nloop]),range,me};
      smooth.mse = {nan([ny,ny,nper,nloop]),nan([nx,nx,nper,nloop]),nan([ne,ne,nper,nloop]),range,memse};
   end
end

%********************************************************************
%! Main loop.

for iloop = 1 : nloop
   
% Next model solution.

   if iloop <= nalt
      [T,R,k,s.Z,s.H,s.d,s.U] = sspace_(m,iloop,false);
      s.nunit = sum(abs(abs(m.eigval(1,1:nb,iloop)) - 1) <= realsmall);
      %s.U(abs(s.U) <= realsmall) = 0;
      %s.Z(abs(s.Z) <= realsmall) = 0;
      if dopredict
         s.Tf = T(1:nf,:);
         s.Rf = R(1:nf,1:ne); % cutt off any forward expansion
         s.kf = k(1:nf,:);
      end
      s.Ta = T(nf+1:end,:);
      s.Ra = R(nf+1:end,1:ne); % cutt off any forward expansion
      s.ka = k(nf+1:end,1);
      % Combine current stdevs with user-supplied stdevs.
      modelstdvec = vec(m.assign(1,end-ne+1:end,iloop));
      [s.Omg,s.Sa,s.Sy,s.exindex,s.eyindex,s.stdvec] = ...
         sigma_(modelstdvec,options.stdvec,s.Ra,s.H);
      % Deterministic trends.
      % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t)      
      s.X = zeros([ny,npout,nper]);
      s.D = zeros([ny,nper]);
      if npout > 0 || options.dtrends
         dtrends_();
      end
      if ~options.dtrends
         s.D(:) = 0;
      end
      init_();
   end

% Next data.

   if iloop <= ndata
      s.data = data(:,:,iloop);
   end
   
   % Adjust measurement variables for determinstic trends.
   s.y1 = s.data;
   if options.dtrends
      s.y1 = s.y1 - s.D;
   end
   s.yindex = ~isnan(s.y1);
   nandata(iloop) = all(all(~s.yindex));

% Predictin error decomposition.

   % Check for exact identification of shocks.
   if options.chkexact && ~strcmpi(options.initcond,'stochastic')
      %s = kalman.chkexact(s);
      chkexact_();
   else
      s.exact = 1;
   end
   % PED matrices indpendent of data.
   % However note that pedind depends on yindex.
   pedind_();
   if options.pedindonly
      continue
   end
   if dosmooth
      smoothind_();
   end
   ped_();
   
% Handle out-of-likelihood parameters.

   % Number of initial conditions to be optimised.
   if strcmpi(options.initcond,'optimal')
      s.ninit = nb;
   else
      % Estimate diffuse initial conditions only if there's at least on
      % diffuse measurement variable.
      if any(any(abs(s.Z(:,1:s.nunit)) > realsmall))
         s.ninit = s.nunit;
      else
         s.ninit = 0;
      end
   end

   % Effect of initial conditions on prediction step.
   % S(t) = d a0(t) / d a0(1:ninit,1)
   s.S = zeros([nb,s.ninit,nper]);
   if s.ninit > 0  
      initcond_();
   end

   % Effect of dtrends parameters on prediction step.
   % Q(t) = d a0(t) / d delta
   s.Q = zeros([nb,npout,nper]);
   if npout > 0
      pout_();
   end

   % Estimate initial conditions and dtrends parameters.
   s.init = zeros([1,s.ninit]);
   s.delta = zeros([1,npout]);
   if s.ninit > 0 || npout > 0
      estimate_();
   end

   % Correct prediction step for estimated initial conditions and dtrends
   % parameters.
   s.ycorrect = zeros([ny,nper]);
   if s.ninit > 0 || npout > 0
      correct0_();
   end

   % Estimate se2.
   if options.relative || strcmpi(options.objective,'mloglik')
      se2_();      
   else
      s.se2 = 1;
   end

   % Evaluate objective function.
   s.obj = 0;
   if strcmpi(options.objective,'mloglik')
      mloglik_();
   elseif strcmpi(options.objective,'prederr')
      prederr_();
   end
   
   if dopredict
      %s = kalman.update(s);
      update_();
      if dosmooth
         %s = kalman.smooth(s);
         smooth_();
      end
   end
   
%! Output arguments.

   if dopredict
      pred.mean{1}(:,2:end,iloop) = s.y0(:,2:end);
      if options.dtrends
         pred.mean{1}(:,2:end,iloop) = pred.mean{1}(:,2:end,iloop) + s.D(:,2:end);
      end
      pred.mean{2}(1:nf,2:end,iloop) = s.f0(:,2:end);
      pred.mean{2}(nf+1:end,:,iloop) = s.a0;
      pred.mean{3}(:,2:end,iloop) = 0;
      pred.mse{2}(nf+1:end,nf+1:end,:,iloop) = s.Pa0;
      if options.relative
         pred.mse{2}(nf+1:end,nf+1:end,:,iloop) = ...
            pred.mse{2}(nf+1:end,nf+1:end,:,iloop)*s.se2;
      end
      if dosmooth
         smooth.mean{1}(:,2:end,iloop) = s.y2(:,2:end);
         if options.dtrends
            smooth.mean{1}(:,2:end,iloop) = smooth.mean{1}(:,2:end,iloop)+ s.D(:,2:end);
         end
         smooth.mean{2}(1:nf,2:end,iloop) = s.f2(:,2:end);
         smooth.mean{2}(nf+1:end,:,iloop) = s.a2;
         smooth.mean{3}(:,2:end,iloop) = s.e2(:,2:end);
         smooth.mse{2}(nf+1:end,nf+1:end,:,iloop) = s.Pa2;
         if options.relative
            smooth.mse{2}(nf+1:end,nf+1:end,:,iloop) = ...
               smooth.mse{2}(nf+1:end,nf+1:end,:,iloop)*s.se2;
         end
      end
   end

   F{1}(:,:,:,iloop) = s.F(:,:,2:end);
   F{2}(:,:,:,iloop) = s.Fi(:,:,2:end);
	if options.relative
      F{1}(:,:,:,iloop) = F{1}(:,:,:,iloop)*s.se2;
      F{2}(:,:,:,iloop) = F{2}(:,:,:,iloop)/s.se2;
   end
   
   pe(:,:,iloop) = s.pe(:,2:end);
   obj(iloop) = s.obj;
   delta(1,:,iloop) = s.delta;
   se2(iloop) = s.se2;
   exact(iloop) = s.exact-1;

end
% End of main loop.

%********************************************************************
%! Backmatter.

% Fix negative variances occuring because of numerical inaccuracy.
if dopredict
   pred.mse{2}(nf+1:end,nf+1:end,:,:) = ...
      time_domain.fixcov(pred.mse{2}(nf+1:end,nf+1:end,:,:));
   if dosmooth
      smooth.mse{2}(nf+1:end,nf+1:end,:,:) = ...
         time_domain.fixcov(smooth.mse{2}(nf+1:end,nf+1:end,:,:));
   end
end

if any(nandata)
   warning_(51,sprintf(' #%g',find(nandata)));
end

% End of function body.





%********************************************************************
%! Nested function dtrends_().
   function dtrends_()
      ttrend = range2ttrend_(range,m.torigin);
      ttrendp = permute(ttrend,[1,3,2]);
      eqtn = m.eqtnF(m.eqtntype == 3);
      % Reset out-of-likelihood parameters to zero.
      % Set up constant deterministic regressors and impact matrix for
      % out-of-likelihood parameters.
      t = 1;
      x0 = m.assign(1,:,iloop);
      x0(1,options.outoflik) = 0;
      offset = sum(m.eqtntype <= 2);
      nname = length(m.name);
      for ieq = find(m.eqtntype == 3)
         s.D(ieq-offset,:) = m.eqtnF{ieq}(x0,1,ttrend);
         occur = find(m.occur(ieq,(m.tzero-1)*nname+(1:nname)));
         for i = 1 : npout
            index = find(occur == options.outoflik(i));
            if ~isempty(index)
               % Evaluate derivatives of dtrends equation w.r.t.
               % out-of-likelihood parameters.
               if ~isempty(m.deqtnF)
                  % Use symbolic derivatives whenever available.
                  s.X(ieq-offset,i,:) = m.deqtnF{ieq}{index}(x0,1,ttrendp);
               else
                  % Numerical derivatives.
                  x0(1,options.outoflik(i)) = 1;
                  s.X(ieq-offset,i,:) = ...
                     m.eqtnF{ieq}(x0,1,ttrendp) - permute(s.D(ieq-offset,:),[1,3,2]);
                  x0(1,options.outoflik(i)) = 0;
               end
            end
         end
      end
   end
% End of nested function dtrend_().





%********************************************************************
%! Nested function initcond_().
   function initcond_()
      % ninit is 0 or nunit.
      s.S(:,:,1) = eye([nb,s.ninit]);
      s.S(:,:,2) = s.Ta(:,1:s.ninit);
      for t = 2 : nper-1
         j = s.yindex(:,t) & ~options.exclude;
         s.S(:,:,t+1) = (s.Ta - s.G0(:,j,t)*s.Z(j,:))*s.S(:,:,t);
      end
   end 
% End of nested function initcond_().





%********************************************************************
%! Nested function pout_().
   function pout_()
      j = s.yindex(:,2) & ~options.exclude;
      s.Q(j,:,2) = 0;
      for t = 2 : nper-1
         j = s.yindex(:,t) & ~options.exclude;
         s.Q(:,:,t+1) = (s.Ta - s.G0(:,j,t)*s.Z(j,:))*s.Q(:,:,t) - s.G0(:,j,t)*s.X(j,:,t);
      end
   end
% End of nested function pout_().





%********************************************************************
%! Nested function estimate_().
% optimise out-of-lik parametes (init, delta) depending on the objective
% function
   function estimate_()
      sum1 = 0;
      sum2 = 0;
      for t = options.objectivesample
         j = s.yindex(:,t) & ~options.exclude;
         M = [s.Z(j,:)*s.S(:,:,t),s.Z(j,:)*s.Q(:,:,t)+s.X(j,:,t)];
         if strcmpi(options.objective,'prederr')
            % w.r.t. weighted prediction errors
            if isempty(options.weighting)
               sum1 = sum1 + transpose(M)*M;
               sum2 = sum2 + transpose(M)*s.pe(j,t);
            else      
               sum1 = sum1 + transpose(M)*options.weighting(j,j)*M;
               sum2 = sum2 + transpose(M)*options.weighting(j,j)*s.pe(j,t);
            end
         else
            % w.r.t. likelihood 
            sum1 = sum1 + transpose(M)*s.Fi(j,j,t)*M;
            sum2 = sum2 + transpose(M)*s.Fipe(j,t);
         end
      end
      % Add 1 as an extra diagonal element to sum1.
      % This trick helps deal with situations when
      % both sum1 and sum2 are numerically small.
      sum1(end+1,end+1) = 1;
      sum1i = pinverse_(sum1);
      sum1i = sum1i(1:end-1,1:end-1);
      est = transpose(sum1i*sum2);
      s.init = est(1:s.ninit);
      s.delta = est(s.ninit+1:end);
   end 
% End of nested function estimate_().





%********************************************************************
%! Nested function correct0_().
function correct0_()
   tmpinit = s.init;
   tmpdelta = s.delta;
   ixinit = abs(tmpinit) > realsmall;
   ixdelta = abs(tmpdelta) > realsmall;
   if any(ixinit) || any(ixdelta)
      tmpinit = vec(tmpinit(ixinit));
      tmpdelta = vec(tmpdelta(ixdelta));
      s.a0(:,1) = s.a0(:,1) + s.S(:,ixinit,1)*tmpinit;
      for t = 2 : nper
         j = s.yindex(:,t);
         correct = s.S(:,ixinit,t)*tmpinit + s.Q(:,ixdelta,t)*tmpdelta;
         s.a0(:,t) = s.a0(:,t) + correct;
         s.ycorrect(:,t) = s.X(:,ixdelta,t)*tmpdelta;
         s.pe(j,t) = s.pe(j,t) - s.Z(j,:)*correct - s.ycorrect(j,t);
         s.Fipe(j,t) = s.Fi(j,j,t)*s.pe(j,t);
         if dopredict
            s.y0(j,t) = s.y0(j,t) + s.ycorrect(j,t);
         end
      end
   end
end
% End of nested function correct0_().





%********************************************************************
%! Nested function se2_().
function se2_()
   nsample = length(options.objectivesample);
   if any(options.exclude)
      s.nobs = sum(sum(s.yindex(:,options.objectivesample) & ~options.exclude(:,ones([1,nsample]))));
   else
      s.nobs = sum(sum(s.yindex(:,options.objectivesample)));
   end
   s.sum_peFipe = 0;
   for t = options.objectivesample
      if any(options.exclude)
         j = s.yindex(:,t) & ~options.exclude;
         tmp = s.pe(j,t)'*(s.F(j,j,t)\s.pe(j,t));
      else
         j = s.yindex(:,t);
         tmp = s.pe(j,t)'*s.Fipe(j,t);
      end
      s.sum_peFipe = s.sum_peFipe + tmp;
   end
   if options.relative
      if s.nobs > 0
         s.se2 = s.sum_peFipe / s.nobs;
         s.sum_peFipe = s.nobs; % == sum_peFipe / se2(iloop);
      else
         s.se2 = 1;
         s.sum_peFipe = 0;
      end
   else
      s.se2 = 1;
   end
end
% End of nested function se2_().





%********************************************************************
%! Nested function mloglik_().
function mloglik_()
   sum_logdet_F = 0;
   for t = options.objectivesample
      j = s.yindex(:,t) & ~options.exclude;
      sum_logdet_F = sum_logdet_F + log(det(s.F(j,j,t)));
   end
   if options.relative
      sum_logdet_F = sum_logdet_F + s.nobs*log(s.se2);
   end
   s.obj = (s.nobs*log(2*pi) + sum_logdet_F + s.sum_peFipe) / 2;
   if imag(s.obj) ~= 0
      s.obj = Inf;
   end
end
% End of nested function mloglik_().





%********************************************************************
%! Nested function prederr_().
   function prederr_()
      s.obj = 0;
      for t = options.objectivesample
         j = s.yindex(:,t) & ~options.exclude;
         if isempty(options.weighting)
            s.obj = s.obj + s.pe(j,t)'*s.pe(j,t);   
         else
            s.obj = s.obj + s.pe(j,t)'*options.weighting(j,j)*s.pe(j,t);   
         end
      end
      s.obj = log(s.obj);
   end
% End of nested function prederr_().





%********************************************************************
%! Nested function init_().
   function init_()
      tmpstable = [false([1,s.nunit]),true([1,nb-s.nunit])];
      % Initialise MSE matrix.
      s.Pa0 = nan([nb,nb,nper]);
      s.Pa0(:,:,1) = 0;
      if isstruct(options.initcond)
         % Caller-supplied initial condition.
         date = round(options.initcond.mse{4} - range(1)) == 0;
         ninitcond = size(options.initcond.mean{2},3);
         s.Pa0(:,:,1) = options.initcond.mse{2}(nf+1:end,nf+1:end,date,min([ninitcond,iloop]));
      elseif nb > s.nunit && strcmpi(options.initcond,'stochastic')
         % Asymptotic initial condition.
         s.Pa0(tmpstable,tmpstable,1) = ...
            symmet_(time_domain.lyapunov(s.Ta(tmpstable,tmpstable),s.Sa(tmpstable,tmpstable,1)));
      end
      % Initialise mean.
      s.a0 = nan([nb,nper]);
      s.a0(:,1) = 0;
      if isstruct(options.initcond)
         % Caller-supplied initial condition.
         date = round(options.initcond.mse{4} - range(1)) == 0;
         ninitcond = size(options.initcond.mean{2},3);
         s.a0(:,1) = options.initcond.mean{2}(nf+1:end,date,min([ninitcond,iloop]));
      elseif ~options.deviation
         % Asymptotic initial condition.
         s.a0(tmpstable,1) = (eye(nb-s.nunit) - s.Ta(tmpstable,tmpstable)) \ s.ka(tmpstable,1);
      end
   end
% End of nested function init_().





%********************************************************************
%! Nested function pedind_().
   function pedind_()
      s.Pa1 = zeros([nb,nb,nper]);
      s.F = nan([ny,ny,nper]);
      s.Fi = s.F;
      s.G0 = nan([nb,ny,nper]);
      s.G1 = s.G0;
      s.ZtFi = s.G0;
      if ispedindin
         for i = 1 : length(pedindlist)
            s.(pedindlist{i}) = pedind(iloop).(pedindlist{i});
         end
      else
         s.Pa1(:,:,1) = s.Pa0(:,:,1);
         for t = 2 : nper
            j = s.yindex(:,t);
            z = any(s.Z ~= 0,1); 
            % Prediction MSE t|t-1.
            tmpindex = ~all(s.Pa1(:,:,t-1) == 0,1);
            s.Pa0(:,:,t) = s.Ta(:,tmpindex)*s.Pa1(tmpindex,tmpindex,t-1)*s.Ta(:,tmpindex)' + s.Sa(:,:,t);
            s.Pa0(:,:,t) = symmet_(s.Pa0(:,:,t));
            % Prediction MSE for measurement variables t|t-1.
            s.F(j,j,t) = symmet_(s.Z(j,z)*s.Pa0(z,z,t)*s.Z(j,z)' + s.Sy(j,j,t));
            if options.chkfmse
               s.Fi(j,j,t) = symmet_(pinverse_(s.F(j,j,t)));
            else
               s.Fi(j,j,t) = symmet_(inv(s.F(j,j,t)));
            end
            % Gain updating t|t-1 -> t|t and t|t-1 -> t+1|t
            s.ZtFi(z,j,t) = s.Z(j,z)'*s.Fi(j,j,t);
            s.G1(:,j,t) = s.Pa0(:,z,t)*s.ZtFi(z,j,t);
            s.G0(:,j,t) = s.Ta*s.G1(:,j,t);
            % Update MSE t|t.
            if t > s.exact
               if any(j)
                  s.Pa1(:,:,t) = symmet_(s.Pa0(:,:,t) - s.G1(:,j,t)*s.Z(j,z)*s.Pa0(z,:,t));   
               else
                  s.Pa1(:,:,t) = s.Pa0(:,:,t);
               end
            end
         end
      end
      if ispedindout
         for i = 1 : length(pedindlist)
            pedindout(iloop).(pedindlist{i}) = s.(pedindlist{i});
         end
      end         
   end
% End of nested function pedind_().





%********************************************************************
%! Nested function smoothind_().
   function smoothind_()
      % Pre-allocation.
      s.Pa2 = s.Pa1;
      s.Pstar = s.Pa1;
      s.Pstar(:,:,end) = NaN;
      for t = nper-1 : -1 : 1
         s.Pstar(:,:,t) = s.Pa1(:,:,t)*s.Ta'*pinverse_(s.Pa0(:,:,t+1));
         s.Pa2(:,:,t) = s.Pa1(:,:,t) + s.Pstar(:,:,t)*(s.Pa2(:,:,t+1) - s.Pa0(:,:,t+1))*s.Pstar(:,:,t)';
      end
   end
% End of nested function smoothind_().





%********************************************************************
%! Nested function chkexact_().
   function chkexact_()
      exindex = any(s.Ra,1)';
      eyindex = any(s.H,1)';
      s.exact = NaN;
      for t = 2 : nper
         cy = sum(s.yindex(:,t));
         stdindex = s.stdvec(:,t) ~= 0;
         ce = sum((exindex & stdindex) | (eyindex & stdindex));
         if cy < ce
            s.exact = t-1;
            break
         end
      end
      if isnan(s.exact)
         s.exact = nper;
      end
   end
% End of nested function chkexact_().






%********************************************************************
%! Nested function ped_().
   function ped_()
      s.y0 = nan([ny,nper]);
      s.pe = s.y0;
      s.Fipe = s.y0;
      for t = 1 : nper
         j = s.yindex(:,t);
         z = any(s.Z ~= 0,1); 
         % Prediction error t.
         s.y0(j,t) = s.Z(j,z)*s.a0(z,t);
         if ~options.deviation
            s.y0(j,t) = s.y0(j,t) + s.d(j);
         end
         s.pe(j,t) = s.y1(j,t) - s.y0(j,t);
         if t < nper
            % Update prediction t+1|t.
            s.a0(:,t+1) = s.Ta*s.a0(:,t) + s.G0(:,j,t)*s.pe(j,t);
            if ~options.deviation
               s.a0(:,t+1) = s.a0(:,t+1) + s.ka;
            end
         end
         s.Fipe(j,t) = s.Fi(j,j,t)*s.pe(j,t);
      end
   end
% End of nested function ped_().





%********************************************************************
%! Nested function update_().
   function update_()
      % Pre-allocate state vectors.
      s.a1 = s.a0;
      s.e1 = zeros([ne,nper]);
      s.RaOmg = nan([nb,ne,nper]);
      s.HOmg = nan([ny,ne,nper]);
      s.L = nan([nb,nb,nper]);
      s.f0 = nan([nf,nper]);
      s.f1 = s.f0;
      s.a1(:,1) = s.a0(:,1);
      for t = 2 : nper
         j = s.yindex(:,t);
         z = any(s.Z ~= 0,1);
         s.a1(:,t) = s.a0(:,t) + s.G1(:,j,t)*s.pe(j,t);   
         s.RaOmg(:,s.exindex,t) = s.Ra(:,s.exindex)*s.Omg(s.exindex,s.exindex,t);
         s.HOmg(j,s.eyindex,t) = s.H(j,s.eyindex)*s.Omg(s.eyindex,s.eyindex,t);
         if any(s.exindex) && any(j)
            s.e1(s.exindex,t) = (s.Z(j,z)*s.RaOmg(z,s.exindex,t))'*s.Fipe(j,t);
         end
         if any(s.eyindex) && any(j)
            s.e1(s.eyindex,t) = s.HOmg(j,s.eyindex,t)'*s.Fipe(j,t);
         end
         % Update missing observables.  
         s.y1(~j,t) = s.Z(~j,z)*s.a1(z,t) + s.H(~j,s.eyindex)*s.e1(s.eyindex,t);
         if ~options.deviation
            s.y1(~j,t) = s.y1(~j,t) + s.d(~j);
         end
         if npout > 0
            s.y1(~j,t) = s.y1(~j,t) + s.ycorrect(~j,t);
         end
         % L used for smoothing shocks.
         s.L(:,:,t) = s.Ta - s.G0(:,j,t)*s.Z(j,:);
         if nf > 0
            s.f0(:,t) = s.Tf*s.a1(:,t-1);
            if ~options.deviation
               s.f0(:,t) = s.f0(:,t) + s.kf;
            end
            Pfa0 = s.Tf*s.Pa1(:,:,t-1)*s.Ta' + s.Rf*s.Omg(:,:,t)*s.Ra';
            s.f1(:,t) = s.f0(:,t) + Pfa0(:,z)*s.Z(j,z)'*s.Fipe(j,t);
         end
      end
   end
% End of nested function update_().





%********************************************************************
%! Nested function smooth_().
   function smooth_()
      % Pre-allocation.
      s.a2 = s.a1;
      s.f2 = s.f1;
      s.e2 = s.e1;
      s.y2 = s.y1;
      j = s.yindex(:,nper);
      r = s.Z(j,:)'*s.Fipe(j,nper);
      for t = nper-1 : -1 : 1
         j = s.yindex(:,t);
         s.a2(:,t) = s.a1(:,t) + s.Pstar(:,:,t)*(s.a2(:,t+1) - s.a0(:,t+1));
         if any(s.eyindex) && any(j)
            s.e2(s.eyindex,t) = s.HOmg(j,s.eyindex,t)'*(s.Fipe(j,t) - s.G0(:,j,t)'*r);
         end
         r = s.Z(j,:)'*s.Fipe(j,t) + s.L(:,:,t)'*r;
         if any(s.exindex)
            s.e2(s.exindex,t) = s.RaOmg(:,s.exindex,t)'*r;
         end
         if any(~j)
            z = any(s.Z ~= 0,1);
            s.y2(~j,t) = s.Z(~j,z)*s.a2(z,t) + s.H(~j,s.eyindex)*s.e2(s.eyindex,t);
            if ~options.deviation
               s.y2(~j,t) = s.y2(~j,t) + s.d(~j);
            end
            if npout > 0
               s.y2(~j,t) = s.y2(~j,t) + s.ycorrect(~j,t);
            end
         end
      end
      if nf > 0
         s.f2(:,2:nper) = s.Tf*s.a2(:,1:nper-1) + s.Rf(:,:)*s.e2(:,2:nper);
         if ~options.deviation
            s.f2(:,2:nper) = s.f2(:,2:nper) + s.kf(:,ones([1,nper-1]));
         end
      end
   end
% End of nested function smooth_().





end
% End of primary function.





%********************************************************************
%! Subfunction sigma_().
% Set up time-varying covariance matrix for shocks.
% Time is along 3rd dimension.

function [Omg,Sa,Sy,exindex,eyindex,stdvec] = sigma_(modelstdvec,userstdvec,Ra,H)
   % Combine model and user-supplied stdvecs.
   [ne,nper] = size(userstdvec);
   nb = size(Ra,1);
   ny = size(H,1);
   modelstdvec = modelstdvec(:,ones([1,nper]));
   stdvec = userstdvec;
   index = isnan(userstdvec);
   stdvec(index) = modelstdvec(index);
   Omg = nan([ne,ne,nper]);
   for t = 1 : nper
      Omg(:,:,t) = diag(stdvec(:,t).^2);
   end
   % Find variances that are non-zero at least in one period.
   index = vech(any(stdvec ~= 0,2));
   exindex = any(Ra,1) & index;
   eyindex = any(H,1) & index;
   % Check if all pages in Omg are identical.
   diffOmg = diff(Omg(:,:,2:end),1,3);
   if all(diffOmg(:) == 0)
      % If so, do the calculations just once, and expand the
      % results in 3rd dimension.
      Sa = Ra(:,exindex)*Omg(exindex,exindex,1)*Ra(:,exindex)';
      Sy = H(:,eyindex)*Omg(eyindex,eyindex,1)*H(:,eyindex)';
      Sa = Sa(:,:,ones([1,nper]));
      Sy = Sy(:,:,ones([1,nper]));
   else
      Sa = zeros([nb,nb,nper]);
      Sy = zeros([ny,ny,nper]);
      for t = 1 : nper
         Sa(:,:,t) = Ra(:,exindex)*Omg(exindex,exindex,t)*Ra(:,exindex)';
         Sy(:,:,t) = H(:,eyindex)*Omg(eyindex,eyindex,t)*H(:,eyindex)';
      end
   end
end
% End of subfunction sigma_().





%********************************************************************
%! Subfuntion pinverse_().

function X = pinverse_(A)
   if isempty(A)
     X = zeros(size(A'),class(A));  
     return
   end
   [m,n] = size(A);
   s = svd(A);
   tol = max(size(A))*eps(s(1));
   r = sum(s > tol);
   if r == 0
      X = zeros(size(A'),class(A));
   elseif r == m
      X = inv(A);
   else
      [U,S,V] = svd(A,0);
      S = diag(1./s(1:r));
      X = V(:,1:r)*S*U(:,1:r)';
   end
end
% End of subfunction pinverse_().

