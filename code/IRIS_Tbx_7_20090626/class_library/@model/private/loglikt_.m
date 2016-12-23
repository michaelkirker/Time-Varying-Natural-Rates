function [obj,se2,FF,pe,delta,Pdelta,supply,pred,smooth,m] = loglikt_(m,data,range,supply,options)
% LOGLIKT_  Version 1 of Kalman filter to evaluate likelihood function in
% time domain.

% The IRIS Toolbox 2009/04/09.
% Copyright (c) 2007-2008 Jaromir Benes.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
ispred = nargout > 7;
issmooth = nargout > 8;

issupplyin = ~isempty(supply);
issupplyout = nargout > 6;

if ~isnumeric(data)
   error('Incorrect type of input argument(s).');
end

if length(options.weighting) == 1
   options.weighting = options.weighting(ones([1,ny]));
end

if any(size(options.weighting) == 1)
   options.weighting = sparse(diag(options.weighting));
end

%********************************************************************
%! Function body.

realsmall = getrealsmall();

if ~issupplyin && issupplyout
   supply = struct();
end

% Parameters concentrated out of likelihood.
pout = options.outoflik;
npout = length(pout);
% If deviation, deterministic trends (and out-of-lik parameters) are not used.
if npout > 0 && any(options.deviation)
   error_(64);
end

% User initial conditions.
if ~isempty(options.init)
   [userinitmean,naninit,userinitmse] = datarequest('init',m,options.init,range);
	userinitmean = squeeze(userinitmean);
   userinitmse = squeeze(userinitmse);      
else
   userinitmean = nan([nb,1]);
   userinitmse = nan([nb,nb,1]);
end
nuserinit = size(userinitmean,2);

% Source data are always numeric arrays without initial condition.
% Add pre-sample initial condition.
ndata = size(data,3);
data = [nan([ny,1,ndata]),data];
range = range(1)-1 : range(end);
nper = length(range);

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
   

ndeviation = length(options.deviation(:));
nchkfmse = length(options.chkfmse(:));

if ischar(options.initcond)
   options.initcond = {options.initcond};
end
ninitcond = length(options.initcond(:));

% Combine model-based std deviations and user-supplied std deviations.
stdvec = stdvec_(m,options.std,range);
nstd = size(stdvec,3);

nloop = max([nuserinit,ndata,nalt,nstd,ndeviation,nchkfmse,ninitcond]);

obj = nan([1,nalt]);
se2 = nan([1,nalt]);
FF = cell([1,2]);
FF(:) = {nan([ny,ny,nper,nloop])};

pe = nan([ny,nper,nalt]);
delta = nan([1,npout,nalt]);
Pdelta = nan([npout,npout,nalt]);

nan_ = @(x) nan(x,m.precision);
if ispred
   me = meta(m,false);
   memse = setfield(me,'mse',true);
   pred.mean = {nan_([ny,nper,nloop]),nan_([nx,nper,nloop]),nan_([ne,nper,nloop]),range,me};
   pred.mse = {nan_([ny,ny,nper,nloop]),nan_([nx,nx,nper,nloop]),nan_([ne,ne,nper,nloop]),range,memse};
   if issmooth
      smooth.mean = {nan_([ny,nper,nloop]),nan_([nx,nper,nloop]),nan_([ne,nper,nloop]),range,me};
      smooth.mse = {nan_([ny,ny,nper,nloop]),nan_([nx,nx,nper,nloop]),nan_([ne,ne,nper,nloop]),range,memse};
   end%if
end%if

%********************************************************************
%! Main loop.

% Index of loops where data are all NaNs.
nandata = false([1,nloop]);

use = struct();
for iloop = 1 : nloop

   %! next deviation

   if iloop <= ndeviation
      use.deviation = options.deviation(iloop);
   end
   
   %! next chkfmse
   if iloop <= nchkfmse
      use.chkfmse = options.chkfmse(iloop);
   end

%! next initcond
   
   if iloop <= ninitcond
      use.initcond = options.initcond{iloop};
   end
   
   %! next model solution

   if iloop <= nalt
      [T,R,k,Z,H,d,U] = sspace_(m,iloop,false);
      nunit = sum(abs(abs(m.eigval(1,:,iloop)) - 1) <= realsmall);
      use.eigval = m.eigval(1,:,iloop);
      % Check if T11 := T(nf+(ix1),ix1) == I ==> model integrated of order 1 or 0.
      ist11eye = iseye(T(nf+(1:nunit),1:nunit));
      U(abs(U) <= realsmall) = 0;
      Z(abs(Z) <= realsmall) = 0;
      if issmooth
         Tf = T(1:nf,:);
         Rf = R(1:nf,1:ne); % cutt off any forward expansion
         kf = k(1:nf,:);
      end
      T = T(nf+1:end,:);
      R = R(nf+1:end,1:ne); % cutt off any forward expansion
      k = k(nf+1:end,1);
      ix1 = 1:nunit;
      ix2 = nunit+1:nb;
   end

   if iloop <= nstd % nstd is always >= nalt
      use.stdvec = stdvec(:,:,iloop);
      [Omega,Sigmaa,Sigmay,ixex,ixey] = omega_();
   end
   
%! next set of initial conditions

   if iloop <= nuserinit
      use.userinitmean = userinitmean(:,iloop);
      use.userinitmse = userinitmse(:,:,iloop);
      userinitmeani = userinitmean(:,iloop);
      userinitmsei = userinitmse(:,:,iloop);
      isuserinit = all(~isnan(userinitmeani)) && all(all(~isnan(userinitmsei)));      
   end

%! next set of observables & deterministic trends

   if iloop <= nalt
      % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t)
      X = zeros([ny,npout,nper]);
      D = zeros([ny,nper]);
      if ~use.deviation
         dtrends_();
      end
   end

   % Get new set of data (inlcuding pre-sample init cond).
   % Adjust measurement variables for determinstic trends.
   y = data(:,:,min([iloop,end])) - D;
   nandata(iloop) = all(all(isnan(y)));
   
%! MSE filter == independent of observables

   if iloop <= nalt
      F = nan([ny,ny,nper]);
      Fi = nan([ny,ny,nper]);
      Zt_Fi = zeros([nb,ny,nper]);
      K = zeros([nb,ny,nper]);
      L = nan([nb,nb,nper]);
      P = nan([nb,nb,nper]);
      ainit = nan([nb,1]);
      if issupplyin
         F(:,:,:) = supply.F;
         Fi(:,:,:) = supply.Fi;
         Zt_Fi(:,:,:) = supply.Zt_Fi;
         K(:,:,:) = supply.K;
         L(:,:,:) = supply.L;
         P(:,:,:) = supply.P; % includes Pinit
         ainit(:) = supply.ainit;
      else
         % Get filter data-independent matrices and init cond for alpha vector.
         % This involves running MSE filter.
         [F(:,:,:),Fi(:,:,:),Zt_Fi(:,:,:),K(:,:,:),L(:,:,:),P(:,:,:),ainit(:)] = logliktdim_(m,use,y,T,k,Z,Sigmaa,Sigmay);
      end
   end
   
   if ~issupplyin && issupplyout && iloop == 1
      supply.F = F;
      supply.Fi = Fi;
      supply.Zt_Fi = Zt_Fi;
      supply.K = K;
      supply.L = L;
      supply.P = P;
      supply.ainit = ainit;
   end

%! mean filter
   
   a = nan([nb,nper]);
   Fi_pe = nan([ny,nper]);
   if ~use.deviation
      a(:,1) = ainit;  
      a(:,2) = T*a(:,1) + k;
   else
      a(:,1:2) = 0;
   end
   meanfilter_();
   
%! out-of-likelihood parameters

   % number of estimated initial conditions
   if ~isempty(options.init)
      ninit = 0;
   elseif strcmpi(use.initcond,'optimal')
      ninit = nb;
   else
      ninit = nunit; 
   end

   % estimated initial conditions
   S = zeros([nb,ninit,nper]); % S(t) = d a(t) / d a(ix1)
   if ninit > 0
      initcond_();
   end

   % dtrends parameters
   Q = zeros([nb,npout,nper]); % Q(t) = d a(t) / d delta
   if npout > 0
      pout_();
   end

   % estimate initial conditions and dtrends parameters
   if ninit > 0 || npout > 0
      init = nan([1,ninit]);
      estimate_();
   end

   % correct prediction step for estimated initial conditions and dtrends parameters
   if ninit > 0 || npout > 0
      correct_();
   end

   % estimate se2
   if strcmpi(options.objective,'mloglik')
      sum_pe_Fi_pe = 0;
      nobs = 0;
      se2_();      
   else
      se2(iloop) = 1;
   end

%! evaluate objective function

   if strcmpi(options.objective,'mloglik')
      obj(iloop) = mloglik_();
   elseif strcmpi(options.objective,'prederr')
      obj(iloop) = prederr_();
   end

%! smoothing

   if issmooth
      % TODO: re-use Pff, Pfa, and smoothing MSE matrices for repeated parameterisations
      
      % run MSE filter for unpredetermined variables
      Pff = nan([nf,nf,nper]);
      Pfa = nan([nf,nb,nper]);
      msefilteru_();

      % run mean filter for unpredetermined variables
      f = nan([nf,nper]);
      meanfilteru_();

      % run MSE smoother
      V = nan([nb,nb,nper]);
      Vff = nan([nf,nf,nper]);
      Vfa = nan([nf,nb,nper]);
      Vee = zeros([ne,ne,nper]);
      Vyy = nan([ny,ny,nper]);
      msesmoother_();

      % run mean smoother
      yhat = nan([ny,nper]);
      ahat = nan([nb,nper]);
      ehat = nan([ne,nper]);
      ehat(:,2:nper) = 0;
      fhat = nan([nf,nper]);
      meansmoother_();
   end

%! output arguments

   if ispred
      pred.mean{2}(nf+1:end,:,iloop) = a;
      pred.mean{3}(:,:,iloop) = 0;
      pred.mse{1}(:,:,:,iloop) = F;
      pred.mse{2}(nf+1:end,nf+1:end,:,iloop) = P;
      pred.mse{3}(ixex|ixey,ixex|ixey,:,iloop) = Omega(ixex|ixey,ixex|ixey,:);
      if options.relative
         pred.mse{1}(:,:,:,iloop) = pred.mse{1}(:,:,:,iloop)*se2(iloop);
         pred.mse{2}(:,:,:,iloop) = pred.mse{2}(:,:,:,iloop)*se2(iloop);
         pred.mse{3}(:,:,:,iloop) = pred.mse{3}(:,:,:,iloop)*se2(iloop);
      end
   %else
   end

   if issmooth
      smooth.mean{1}(:,:,iloop) = yhat + D;
      smooth.mean{2}(1:nf,:,iloop) = fhat;
      smooth.mean{2}(nf+1:end,:,iloop) = ahat;
      smooth.mean{3}(:,:,iloop) = ehat;
      smooth.mse{1}(:,:,:,iloop) = Vyy;
      smooth.mse{2}(:,:,:,iloop) = [Vff,Vfa;permute(Vfa,[2,1,3]),V];
      smooth.mse{3}(:,:,:,iloop) = Vee;
      if options.relative
         smooth.mse{1}(:,:,:,iloop) = smooth.mse{1}(:,:,:,iloop)*se2(iloop);
         smooth.mse{2}(:,:,:,iloop) = smooth.mse{2}(:,:,:,iloop)*se2(iloop);
         smooth.mse{3}(:,:,:,iloop) = smooth.mse{3}(:,:,:,iloop)*se2(iloop);
      end
   end

   FF{1}(:,:,:,iloop) = F;
   FF{2}(:,:,:,iloop) = Fi;
	if options.relative
      FF{1}(:,:,:,iloop) = FF{1}(:,:,:,iloop)*se2(iloop);
      FF{2}(:,:,:,iloop) = FF{2}(:,:,:,iloop)/se2(iloop);
   end
   
end
% End of main loop.

%********************************************************************
%! backmatter

% get rid of negative variances occuring because of numerical inaccuracy
if ispred
   for i = 1 : 3
      pred.mse{i}(:,:,:,:) = time_domain.fixcov(pred.mse{i});
      if issmooth
         smooth.mse{i}(:,:,:,:) = time_domain.fixcov(smooth.mse{i});
      end
   end
end

% Delete first observation (= initial condition) from pred error vector and FMSE matrices.
pe(:,1,:) = [];
FF{1}(:,:,1,:) = [];
FF{2}(:,:,1,:) = [];

if any(nandata)
   warning_(51,sprintf(' #%g',find(nandata)));
end
save ss0.mat;

% End of function body.

%********************************************************************
%! Nested function meanfilter_().

function meanfilter_() 
   % range extended at the beginning
   % no data in period 1
   for t = 2 : nper
      ixy = ~isnan(y(:,t));
      ixz = any(Z(ixy,:) ~= 0,1);
      pe(ixy,t,iloop) = y(ixy,t) - Z(ixy,ixz)*a(ixz,t);
      if ~use.deviation
         pe(ixy,t,iloop) = pe(ixy,t,iloop) - d(ixy,1);
      end
      Fi_pe(ixy,t) = Fi(ixy,ixy,t)*pe(ixy,t,iloop);
      %Fi_pe(ixy,t) = F(ixy,ixy,t) \ pe(ixy,t,iloop);
      if t < nper
         if ist11eye
            % make use of T21 = 0
            a(ix1,t+1) = a(ix1,t) + T(ix1,ix2)*a(ix2,t);
         else
            a(ix1,t+1) = T(ix1,:)*a(:,t);
         end
         a(ix2,t+1) = T(ix2,ix2)*a(ix2,t);
         if ~use.deviation
            a(:,t+1) = a(:,t+1) + k(:,1);
         end
         if any(ixy)
            a(:,t+1) = a(:,t+1) + K(:,ixy,t)*pe(ixy,t,iloop);
         end
      end
   end
end
% End of nested function meanfilter_().

%********************************************************************
%! Nested function msefilteru_().
  
function msefilteru_()
   % mse filter for xf variables
   Pff(:,:,2) = Tf*P(:,:,1)*transpose(Tf) + Rf(:,ixex)*sparse(Omega(ixex,ixex,2))*transpose(Rf(:,ixex));
   Pfa(:,:,2) = Tf*P(:,:,1)*transpose(T) + Rf(:,ixex)*sparse(Omega(ixex,ixex,2))*transpose(R(:,ixex));
   for t = 2 : nper
      ixy = ~isnan(y(:,t));
      ixz = any(Z(ixy,:) ~= 0,1);
      if any(ixy)
         Kf = Tf*P(:,ixz,t)*Zt_Fi(ixz,ixy,t);
         Lf = Tf - Kf*Z(ixy,:);
      else
         Lf = Tf;
      end
      if t < nper
         Pff(:,:,t+1) = Tf*P(:,:,t)*transpose(Lf) + Rf(:,ixex)*sparse(Omega(ixex,ixex,t+1))*transpose(Rf(:,ixex));
         Pfa(:,:,t+1) = Tf*P(:,:,t)*transpose(L(:,:,t)) + Rf(:,ixex)*sparse(Omega(ixex,ixex,t+1))*transpose(R(:,ixex));
      end
   end
end
% End of nested function msefilteru_().

%********************************************************************
%! Nested function meanfilteru_().

function meanfilteru_()
   % mean filter for xf variables
   f(:,2:nper) = Tf*a(:,1:nper-1);
   if ~use.deviation
      index = (kf ~= 0);
      f(index,2:nper) = f(index,2:nper) + kf(index,ones([1,nper-1]));
   end
end
% End of nested function meanfilteru_().

%********************************************************************
%! Nested function msesmoother_().

function msesmoother_()
   N = zeros([nb,nb]);
   for t = nper : -1 : 2
      ixy = ~isnan(y(:,t));
      Omegax = sparse(Omega(ixex,ixex,t));
      Omegay = sparse(Omega(ixey,ixey,t));
      Omega_Ht = Omegay*transpose(H(ixy,ixey));
      Omega_Rt = Omegax*transpose(R(:,ixex));
      % use N(t)
      % MSE for measurement and transition residuals
      Vee(ixey,ixey,t) = Omegay - Omega_Ht*(Fi(ixy,ixy,t) + transpose(K(:,ixy,t))*N*K(:,ixy,t))*transpose(Omega_Ht);
      W = Omega_Ht*(transpose(Zt_Fi(:,ixy,t)) - transpose(K(:,ixy,t))*N*L(:,:,t));
      Vee(ixex,ixey,t) = -Omega_Rt*transpose(W);
      Vee(ixey,ixex,t) = transpose(Vee(ixex,ixey,t));
      % update N(t) --> N(t-1)
      update_();
      Vee(ixex,ixex,t) = Omegax - Omega_Rt*N*transpose(Omega_Rt);
      if any(any(N ~= 0))
         V(:,:,t) = P(:,:,t) - P(:,:,t)*N*P(:,:,t);
         Vff(:,:,t) = Pff(:,:,t) - Pfa(:,:,t)*N*transpose(Pfa(:,:,t));
         Vfa(:,:,t) = Pfa(:,:,t) - Pfa(:,:,t)*N*P(:,:,t);
      else
         V(:,:,t) = P(:,:,t);
         Vff(:,:,t) = Pff(:,:,t);
         Vfa(:,:,t) = Pfa(:,:,t);
         Vee(ixex,ixex,t) = Omega(ixex,ixex,t);
      end
      Aux = Z*(-P(:,:,t)*transpose(W))*transpose(H(:,ixey)); % Z * MSE alpha(t) epsilon(ixey,t) * H'
      Vyy(:,:,t) = Z*V(:,:,t)*transpose(Z) + H(:,ixey)*Vee(ixey,ixey,t)*transpose(H(:,ixey)) + Aux + transpose(Aux);
      % Set cov of observables exactly to zero.
      Vyy(ixy,ixy,t) = 0;
   end
   % initial condition
   if any(any(N ~= 0))
      N = transpose(L(:,:,1))*N*L(:,:,1);
   end
   if any(any(N ~= 0))
      V(:,:,1) = P(:,:,1) - P(:,:,1)*N*P(:,:,1);
   else
      V(:,:,t) = P(:,:,t);
   end

%********************************************************************
%! Nested nested function update_().

   function update_()
      % N(t) --> N(t-1)
      if any(any(N ~= 0))
         N = transpose(L(:,:,t))*N*L(:,:,t);
      end
      if any(ixy)
         N = N + Zt_Fi(:,ixy,t)*Z(ixy,:);
      end
   end
% End of nested nested function update_().

end 
% End of nested function msesmoother_().

%********************************************************************
%! Nested function meansmoother_().

function meansmoother_()
   r = zeros([nb,1]);
   for t = nper : -1 : 2
      ixy = ~isnan(y(:,t));
      Omegax = sparse(Omega(ixex,ixex,t));
      Omegay = sparse(Omega(ixey,ixey,t));
      Omega_Ht = Omegay*transpose(H(ixy,ixey));
      Omega_Rt = Omegax*transpose(R(:,ixex));
      % use r(t)
      ehat(ixey,t) = Omega_Ht*(Fi_pe(ixy,t) - transpose(K(:,ixy,t))*r);
      % update r(t) --> r(t-1)
      update_();
      if any(r ~= 0)
         ahat(:,t) = a(:,t) + P(:,:,t)*r;
         fhat(:,t) = f(:,t) + Pfa(:,:,t)*r;
         ehat(ixex,t) = Omega_Rt*r;
      else
         ahat(:,t) = a(:,t);
         fhat(:,t) = f(:,t);
         ehat(ixex,t) = 0;
      end
   end
   % pre-sample initial condition
   r = transpose(L(:,:,1))*r;
   if any(r ~= 0)
      ahat(:,1) = a(:,1) + P(:,:,1)*r;
   else
      ahat(:,1) = a(:,1);
   end
   % unpredetermined variables
   fhat(:,2:nper) = Tf*ahat(:,1:nper-1) + Rf(:,ixex)*ehat(ixex,2:nper);
   % measurement variables
   yhat(:,2:nper) = Z*ahat(:,2:nper) + H(:,ixey)*ehat(ixey,2:nper);
   % add constants
   if ~use.deviation
      index = (kf ~= 0);
      fhat(index,2:nper) = fhat(index,2:nper) + kf(index,ones([1,nper-1]));
      index = (d ~= 0);
      yhat(index,2:nper) = yhat(index,2:nper) + d(index,ones([1,nper-1]));
   end
   % correct measurement variables for estimated deterministic trends
   ixdelta = abs(delta(1,:,iloop)) > realsmall;
   if any(ixdelta)
      delta_ = transpose(delta(1,ixdelta,iloop));
      for t = 1 : nper
         yhat(:,t) = yhat(:,t) + X(:,ixdelta,t)*delta_;
      end
   end
   
%********************************************************************
%! Nested nested function update_().

   function update_()
      % r(t) --> r(t-1)
      if any(r ~= 0)
         r = transpose(L(:,:,t))*r;
      end
      if any(ixy)
         r = r + Zt_Fi(:,ixy,t)*pe(ixy,t,iloop);
      end
   end
% End of nested nested function update_().

end
% End of nested function smooth_().

%********************************************************************
%! Nested function dtrends_().

function dtrends_()
   ttrend = range2ttrend_(range,m.torigin);
   ttrendp = permute(ttrend,[1,3,2]);
   eqtn = m.eqtnF(m.eqtntype == 3);
   % reset out-of-likelihood parameters to zero
   % set up constant deterministic regressors and impact matrix for out-of-likelihood parameters
   t = 1;
   x0 = m.assign(1,:,min([end,iloop]));
   x0(1,pout) = 0;
   offset = sum(m.eqtntype <= 2);
   nname = length(m.name);
   for ieq = find(m.eqtntype == 3)
      D(ieq-offset,:) = m.eqtnF{ieq}(x0,1,ttrend);
      occur = find(m.occur(ieq,(m.tzero-1)*nname+(1:nname)));
      for i = 1 : length(pout)
         index = find(occur == pout(i));
         if ~isempty(index)
            % evaluate derivatives of dtrends equation w.r.t. out-of-likelihood parameters
            if ~isempty(m.deqtnF)
               % use symbolic derivatives whenever availables
               X(ieq-offset,i,:) = m.deqtnF{ieq}{index}(x0,1,ttrendp);
            else
               % numerical derivatives
               x0(1,pout(i)) = 1;
               X(ieq-offset,i,:) = m.eqtnF{ieq}(x0,1,ttrendp) - permute(D(ieq-offset,:),[1,3,2]);
               x0(1,pout(i)) = 0;
            end
         end
      end
   end
end
% End of nested function dtrend_().

%********************************************************************
%! Nested function initcond_().

function initcond_()
   % ninit is 0 or nunit
   S(:,:,1) = eye([nb,ninit]);
   S(:,:,2) = T(:,1:ninit);
   for t = 2 : nper-1
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      S(:,:,t+1) = (T - K(:,ixy,t)*Z(ixy,:))*S(:,:,t);
   end
end 
% End of nested function initcond_().

%********************************************************************
%! Nested function pout_().

function pout_()
   ixy = ~isnan(y(:,2));
   Q(ixy,:,2) = 0;
   for t = 2 : nper-1
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      Q(:,:,t+1) = (T - K(:,ixy,t)*Z(ixy,:))*Q(:,:,t) - K(:,ixy,t)*X(ixy,:,t);
   end
end
% End of nested function pout_().

%********************************************************************
%! Nested function estimate_().
% optimise out-of-lik parametes (init, delta) depending on the objective function

function estimate_()
   sum1 = 0;
   sum2 = 0;
   for t = options.objectivesample
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      M = [Z(ixy,:)*S(:,:,t),Z(ixy,:)*Q(:,:,t)+X(ixy,:,t)];
      if strcmpi(options.objective,'prederr')
         % w.r.t. weighted prediction errors
         if isempty(options.weighting)
            sum1 = sum1 + transpose(M)*M;
            sum2 = sum2 + transpose(M)*pe(ixy,t,iloop);
         else      
            sum1 = sum1 + transpose(M)*options.weighting(ixy,ixy)*M;
            sum2 = sum2 + transpose(M)*options.weighting(ixy,ixy)*pe(ixy,t,iloop);
         end
      else
         % w.r.t. likelihood 
         sum1 = sum1 + transpose(M)*Fi(ixy,ixy,t)*M;
         sum2 = sum2 + transpose(M)*Fi_pe(ixy,t);
      end
   end
   [sum1i,r] = ginverse(sum1);
   est = transpose(sum1i*sum2);
   init = est(1:ninit);
   delta(1,:,iloop) = est(ninit+1:end);
end 
% End of nested function estimate_().

%********************************************************************
%! Nested function correct_().

function correct_()
   ixinit = abs(init) > realsmall;
   ixdelta = abs(delta(1,:,iloop)) > realsmall;
   if any(ixinit) || any(ixdelta)
      init_ = transpose(init(ixinit));
      delta_ = transpose(delta(1,ixdelta,iloop));
      a(:,1) = a(:,1) + S(:,ixinit,1)*init_;
      for t = 2 : nper
         ixy = ~isnan(y(:,t));
         aux = S(:,ixinit,t)*init_ + Q(:,ixdelta,t)*delta_;
         a(:,t) = a(:,t) + aux;
         pe(ixy,t,iloop) = pe(ixy,t,iloop) - Z(ixy,:)*aux - X(ixy,ixdelta,t)*delta_;
      end
      for t = 2 : nper
         ixy = ~isnan(y(:,t));
         Fi_pe(ixy,t) = Fi(ixy,ixy,t)*pe(ixy,t,iloop);
      end
   end
end
% End of nested function correct_().

%********************************************************************
%! Nested function se2_().

function se2_()
   for t = options.objectivesample
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      nobs = nobs + sum(ixy);
      sum_pe_Fi_pe = sum_pe_Fi_pe + transpose(pe(ixy,t,iloop))*Fi_pe(ixy,t);
   end
   se2(iloop) = 1;
   if nobs > 0
      if options.relative
         se2(iloop) = sum_pe_Fi_pe / nobs;
         sum_pe_Fi_pe = nobs; % == sum_pe_Fi_pe / se2(iloop);
      end     
   else
      sum_pe_Fi_pe = 0;
   end
end
% End of nested function se2_().

%********************************************************************
%! Nested function mloglik_().

function output = mloglik_()
   sum_logdet_F = 0;
   for t = options.objectivesample
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      sum_logdet_F = sum_logdet_F + log(det(F(ixy,ixy,t)));
   end
   if options.relative
      sum_logdet_F = sum_logdet_F + nobs*log(se2(iloop));
   end
   output = (nobs*log(2*pi) + sum_logdet_F + sum_pe_Fi_pe) / 2;
   if imag(output) ~= 0
      output = 1e10;
   end
end
% End of nested function mloglik_().

%********************************************************************
%! Nested function prederr_().

function output = prederr_()
   output = 0;
   for t = options.objectivesample
      ixy = ~isnan(y(:,t)) & ~options.exclude;
      if isempty(options.weighting)
         output = output + transpose(pe(ixy,t,iloop))*pe(ixy,t,iloop);   
      else
         output = output + transpose(pe(ixy,t,iloop))*options.weighting(ixy,ixy)*pe(ixy,t,iloop);   
      end
   end
   output = log(output);
end
% End of nested function prederr_().

%********************************************************************
%! Nested function omega_().
% Set up time-varying covariance matrix for shocks.
% Time is along 3rd dimension.

function [Omega,Sigmaa,Sigmay,ixex,ixey] = omega_()
   Omega = nan([ne,ne,nper]);
   for t = 1 : nper
      Omega(:,:,t) = diag(stdvec(:,t,iloop).^2);
   end
   % Find variances that are non-zero at least in one period.
   index = vech(any(stdvec(:,:,iloop) ~= 0,2));
   if issmooth
      ixex = any([R;Rf],1) & index;
   else
      ixex = any(R,1) & index;
   end
   ixey = any(H,1) & index;
   Sigmaa = zeros([nb,nb,nper]);
   Sigmay = zeros([ny,ny,nper]);
   for t = 1 : nper
      Sigmaa(:,:,t) = R(:,ixex)*Omega(ixex,ixex,t)*transpose(R(:,ixex));
      Sigmay(:,:,t) = H(:,ixey)*Omega(ixey,ixey,t)*transpose(H(:,ixey));
   end
end
% End of nested function omega_().

end
% End of primary function.





%********************************************************************
%! Subfunction omega_().
% Set up time-varying covariance matrix for shocks.
% Time is along 3rd dimension.

function [Omg,Sa,Sy,exindex,eyindex,stdvec] = omega_(modelstdvec,userstdvec,Ra,H)
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
   Sa = zeros([nb,nb,nper]);
   Sy = zeros([ny,ny,nper]);
   for t = 1 : nper
      Sa(:,:,t) = Ra(:,exindex)*Omg(exindex,exindex,t)*transpose(Ra(:,exindex));
      Sy(:,:,t) = H(:,eyindex)*Omg(eyindex,eyindex,t)*transpose(H(:,eyindex));
   end
end
% End of subfunction omega_().
