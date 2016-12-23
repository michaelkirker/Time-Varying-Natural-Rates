function [obj,pe,pred,smooth,Q] = nsfilter(this,data,varargin)
% NSFILTER  Non-stochastic Kalman filter.

% The IRIS Toolbox 2009/04/27.
% Copyright 2007-2009 Jaromir Benes.

% Get array of measurement variables.
[data,range,varargin,outputformat] = loglikdata_(this,data,varargin{:});

default = {
   'optiminit',false,@islogical,...
   'deviation',false,@islogical,...
   'weighting',[],@(x) isnumeric(x),...
};
options = passvalopt(default,varargin);

%********************************************************************
%! Function body.

realsmall = getrealsmall();
[ny,nx,nf,nb,ne,np,nalt] = size_(this);
% add pre-sample initial condition
data = [nan([ny,1,size(data,3)]),data];
range = range(1)-1:range(end);
[ny,nper,ndata] = size(data);
nloop = max([nalt,ndata]);

% pre-allocate output data
nan_ = @(x) nan(x,this.precision);
me = meta(this,false);
pred = {nan_([ny,nper,nloop]),nan_([nx,nper,nloop]),nan_([ne,nper,nloop]),range,me};
smooth = {nan_([ny,nper,nloop]),nan_([nx,nper,nloop]),nan_([ne,nper,nloop]),range,me};
obj = zeros([1,nloop]);
pe = nan([ny,nper,nloop]);
   
if isempty(options.weighting)
   W = [];
elseif any(size(options.weighting) == 1)
   W = sparse(diag(options.weighting));
else
   W = options.weighting;
end

%********************************************************************
%! Main loop.

for iloop = 1 : nloop 
   % update observables
   if iloop <= ndata
      ystar = data(:,:,iloop);
      ixy = ~all(isnan(ystar),2); % observables that have some numbers
      % Check for unbalanced panel. Excluding all-nan observables first.
      if any( ~all(isnan(ystar(ixy,:)),1) & any(isnan(ystar(ixy,:)),1) )
         error('Cannot run NSFILTER with unbalanced panel of observables.');
      end
   end
   % Update solution.
   if iloop <= nalt
      [T,R,K,Z,H,D,U] = sspace(this,iloop);
      nunit = sum(abs(abs(this.eigval(1,:,iloop)) - 1) <= realsmall);
      if any(abs(Z(:,1:nunit) ) > realsmall)
         error('Cannot run NSFILTER with non-stationary observables.');
      end
      Tf = T(1:nf,:);
      Rf = R(1:nf,:);
      Kf = K(1:nf,:);
      T = T(nf+1:end,:);
      R = R(nf+1:end,:);
      K = K(nf+1:end,:);
      ixstable = nunit+1:nb;
      % find structural shocks with non-zero std deviations
      stdvec = this.assign(1,end-sum(this.nametype == 3)+1:end,iloop);
      ixe = stdvec ~= 0;
      if sum(ixe) ~= sum(ixy)
         error('Number of active shocks must match number of available observables.');
      end
      % effect of all shocks on all observables
      %$ Q = Z(:,ixstable)*R(ixstable,:) + H;
      Q = Z*R + H;
      Qi = inv(Q(ixy,ixe));
   end
   % preallocate filter data
   y = zeros([ny,nper]);
   xf = zeros([nf,nper]);
   a = zeros([nb,nper]);
   yhat = ystar;
   xfhat = xf;
   ahat = a;
   ehat = zeros([ne,nper]);
   % set initial condition
   if ~options.deviation
      % unconditional mean
      a(ixstable,1) = (eye(nb-nunit) - T(ixstable,ixstable)) \ K(ixstable,1);
   end
   % run non-stochastic filter
   filter_();

   if options.optiminit
      % compute optimal correction in initial condition
      init = initcond_();
      if any(abs(init) > realsmall)
         % re-run filter with optimal initial condition
         a(:,1) = a(:,1) + init;
         %pe0 = pecorrection_();
         filter_();
      end
   end
   
   % Calculate xf and y.
   postfilter_();
   
   % objective function (wsum of prediction errors)
   objfcn_();
   
   pred{1}(:,:,iloop) = y;
   pred{2}(:,:,iloop) = [xf;a];
   pred{3}(:,:,iloop) = 0;
   smooth{1}(:,:,iloop) = yhat;
   smooth{2}(:,:,iloop) = [xfhat;ahat];
   smooth{3}(:,:,iloop) = ehat;

   % Create database of time series with prediction errors.
   pe_ = pe;
   pe = struct();
   template = tseries();
   for i = find(this.nametype == 1)
      if this.log(i)
         pe_(i,:,:) = exp(pe_(i,:,:));
      end
      pe.(this.name{i}) = replace(template,permute(pe_(i,:,:),[2,1,3]),range(1),this.name(i));
   end

end

%********************************************************************
%! Backmatter.

% Convert datapacks to databases if requested.
if strcmpi(outputformat,'dbase')
   pred = dp2db(this,pred);
   smooth = dp2db(this,smooth);
end

% End of primary function.

   %********************************************************************
   %! Nested function filter_().
   
   function filter_()
      ahat(:,1) = a(:,1);
      for t = 2 : nper
         % predict
         a(:,t) = T*ahat(:,t-1);
         if ~options.deviation
            a(:,t) = a(:,t) + K;
         end
         %$ y(:,t) = Z(:,ixstable)*a(ixstable,t);
         y(:,t) = Z*a(:,t); %$
         if ~options.deviation
            y(:,t) = y(:,t) + D;
         end
         ahat(:,t) = a(:,t);
         % Filter if observables are available.
         if all(~isnan(ystar(ixy,t)))
            pe(ixy,t,iloop) = ystar(ixy,t) - y(ixy,t);
            ehat(ixe,t) = Qi*pe(ixy,t,iloop);
            ahat(:,t) = ahat(:,t) + R(:,ixe)*ehat(ixe,t);  
         end
      end
   end
   % End of nested function filter_().
   
   %********************************************************************
   %! Nested function postfilter_().
   
   function postfilter_()
      xf(:,2:end) = Tf*ahat(:,1:end-1);
      if ~options.deviation
         xf(:,2:end) = xf(:,2:end) + Kf(:,ones([1,nper-1]));
      end
      xfhat(:,2:end) = xf(:,2:end) + Rf(:,ixe)*ehat(ixe,2:end);
      yhat(:,2:end) = y(:,2:end) + Q(:,ixe)*ehat(ixe,2:end);
   end
   
   %********************************************************************
   %! Nested function initcond_().
   % Optimise initial condition w.r.t. to objective function.
   
   function [init,S,M] = initcond_()
      % S(t) := da(t) / da(1)
      S = zeros([nb,nb,nper]);
      % M := dy(t) / da(1)
      M = zeros([ny,nb,nper]);
      S(:,:,1) = eye(nb);
      S(:,:,2) = T;
      G = T*R(:,ixe)*Qi;
      for t = 3 : nper
         S(:,:,t) = (T - G*Z(ixy,:))*S(:,:,t-1);
      end
      A = 0;
      B = 0;
      for t = 2 : nper   
         if all(~isnan(pe(ixy,t,iloop)))
            M(ixy,:,t) = Z(ixy,:)*S(:,:,t);
            if isempty(W)
              A = A + transpose(M(ixy,:,t))*M(ixy,:,t);
              B = B + transpose(M(ixy,:,t))*pe(ixy,t,iloop);
            else
              A = A + transpose(M(ixy,:,t))*W(ixy,ixy)*M(ixy,:,t);
              B = B + transpose(M(ixy,:,t))*W(ixy,ixy)*pe(ixy,t,iloop);
            end
         end
      end
      init = ginverse(A)*B;
   end 
   % End of nested function initcond_().
   
   %********************************************************************
   %! Nested function pecorrection_().
   
   function pe0 = pecorrection_()
      pe0 = pe;
      for t = 2 : nper
         if all(~isnan(pe(ixy,t,iloop)))
            pe0(ixy,t,iloop) = pe0(ixy,t,iloop) - M(ixy,:,t)*init;
         end      
      end
   end
   
   %********************************************************************
   %! Nested function objfcn_().
   % Value of objective function (weighted sum of prediction errors).
   
   function objfcn_()
      if isempty(W)
         for t = 2 : nper
            if all(~isnan(pe(ixy,t,iloop)))
               obj(iloop) = obj(iloop) + transpose(pe(ixy,t,iloop))*pe(ixy,t,iloop);
            end
         end
      else
         for t = 2 : nper
            if all(~isnan(pe(ixy,t,iloop)))
               obj(iloop) = obj(iloop) + transpose(pe(ixy,t,iloop))*W(ixy,ixy)*pe(ixy,t,iloop);
            end
         end
      end
   end
   % End of nested function objfcn_().

end
% End of primary function.
