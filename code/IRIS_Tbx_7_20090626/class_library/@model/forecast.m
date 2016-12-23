function [func,fcon,Pi] = forecast(m,init,range,cond,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.forecast">idoc model.forecast</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse the The IRIS Toolbox documentation found in the Contents pane.

% The IRIS Toolbox 2009/01/26.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'anticipate',true,@islogical,...
   'deviation',false,@islogical,...
   'dtrends','auto',@(x) islogical(x) || strcmpi(x,'auto'),...
   'initcond','data',@(x) any(strcmpi(x,{'data','fixed'})) || isnumeric(x),...
   'output','auto',@(x) any(strcmpi(x,{'auto','dpack','dbase'})),...
   'precision',m.precision,@(x) any(strcmpi(x,{'double','single'})),...
   'std',[],@(x) isempty(x) || isstruct(x),...
   'tolmse',getrealsmall('mse'),@(x) isnumeric(x) && length(x) == 1,...
};
options = passvalopt(default,varargin{:});

if ischar(options.dtrends)
   options.dtrends = ~options.deviation;
end

if isempty(cond)
  cond = struct();
end

%********************************************************************
%! Function body.

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

range = range(1) : range(end);
[ny,nx,nf,nb,ne,np,nalt] = size_(m);
nper = length(range);

nanticipate = length(options.anticipate(:));
ndeviation = length(options.deviation(:));
ndtrends = length(options.dtrends(:));

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
shock = datarequest('e',m,cond,range);
cond = datarequest('y',m,cond,range);
ncond = size(cond,3);
nshock = size(shock,3);

% get std deviations of shocks
stdvec = stdvec_(m,options.std,range);
nstd = size(stdvec,3);

% total number of cycles
nloop = max([nalt,nanticipate,ndeviation,ndtrends,ninit,ncond,nshock,nstd]);

% pre-allocate output datapack
nan_ = @(dim) nan([dim,1+nper,nloop],options.precision);
func = struct();
func.mean = {nan_(ny),nan_(nx),nan([ne,1+nper,nloop]),[range(1)-1,range],meta(m,false)};
func.mse = {nan_([ny,ny]),nan_([nx,nx]),nan_([ne,ne]),[range(1)-1,range],meta(m,true)};
if nargout > 1
   fcon = struct();
   fcon.mean = {nan_(ny),nan_(nx),nan([ne,1+nper,nloop]),[range(1)-1,range],meta(m,false)};
   fcon.mse = {nan_([ny,ny]),nan_([nx,nx]),nan_([ne,ne]),[range(1)-1,range],meta(m,true)};   
end%if

Pi = nan([1,nloop]); % test statistic

underdet = []; % index of underdetermined systems
nansolution = []; % index of NaN solutions
nanexpand = []; % index of NaN expansions

use = struct();

for iloop = 1 : nloop

   if iloop <= ndeviation
      use.deviation = options.deviation(iloop);
   end
   
   if iloop <= ndtrends
      use.dtrends = options.dtrends(iloop);
   end

   if iloop <= nanticipate
      use.anticipate = options.anticipate(iloop);
   end

   if iloop <= ncond
      % measurement conditions including detereministic trends
      use.conddet = cond(:,:,iloop);
      use.condindex = ~isnan(use.conddet);
      use.lastcond = max([0,find(any(use.condindex,1),1,'last')]); % last imposed tune
      use.condindex = use.condindex(:,1:use.lastcond);
      use.condindex = vech(use.condindex);
   end

   if iloop <= nalt
      % model solution
      [use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.Omega] = sspace_(m,iloop,true);
      % matrices for forward expansion
      use.expand = cell(size(m.expand));
      for i = 1 : length(m.expand)
         use.expand{i} = m.expand{i}(:,:,iloop);
      end
      % deterministic trends
      if options.dtrends
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
      use.activeresid = vech(use.stdvec(:,1:use.lastcond) > 0);
   end

   if iloop <= nalt || iloop <= ncond
      % conditions adjusted for deterministic trends
      use.cond = use.conddet;
      if use.dtrends
         use.cond = use.cond - use.W;   
      end     
   end

   if iloop <= ninit
      % init condition mean and MSE
      use.initmean = initmean(:,1,iloop);
      if ~isempty(initmse) && ~strcmpi(options.initcond,'fixed')
         use.initmse = initmse(:,:,iloop); 
         use.activeinit = vech(abs(diag(use.initmse)) > options.tolmse);
      elseif isnumeric(options.initcond)
         if iloop <= nalt
            error('Option INITCOND not implemented with Kalman smoother yet.'); 
         end%if
      else
         use.initmse = sparse(zeros(length(use.initmean)));
         use.activeinit = false([1,length(use.initmean)]);
      end
   end   
   
   if sum(use.condindex) > sum(use.activeinit) + sum(use.activeresid)
      underdet(end+1) = iloop;
      continue
   end

   if iloop <= nshock
      use.shock = shock(:,:,iloop);
      use.lastshock = max([0,find(any(use.shock ~= 0),1,'last')]); % last imposed shock
   end

   % furthest anticipated shock needed
   if use.anticipate
      use.last = max([use.lastshock,use.lastcond]);   
      use.tplusk = use.last;
   else
      use.last = 0;
      use.tplusk = max([0,find(any(imag(use.shock) ~= 0),1,'last')]);
   end
 
   if ne > 0
      % Expansion available up to t+k0.
      if use.tplusk > size(use.R,2)/ne
         [use.R,use.expand{5}] = expand_(use.R,use.tplusk-1,use.expand{1:5});
      end
   end

   % Compute multipliers of initial condition, unanticipated and
   % anticipated shocks.
   if use.lastcond > 0
      if iloop <= nalt || iloop <= ncond || iloop <= nstd
         % Multipliers of initial condition and unanticipated shocks.
         % This is needed whether forecast is anticipated or not.
         [use.DyDa0,use.DaDa0,use.DfDa0] = time_domain.multiplierinit(...
            use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
            use.lastcond,use.activeinit);
         [use.DyDeu,use.DaDeu,use.DfDeu] = time_domain.multipliereu(...
            use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
            use.lastcond,use.activeresid);
         use.DfaDa0eu = [];
         for t = 1 : use.lastcond
            use.DfaDa0eu = [...
               use.DfaDa0eu;...
               use.DfDa0((t-1)*nf+(1:nf),:),use.DfDeu((t-1)*nf+(1:nf),:);...
               use.DaDa0((t-1)*nb+(1:nb),:),use.DaDeu((t-1)*nb+(1:nb),:);...
            ];
         end
      end
      if iloop <= nalt || iloop <= ncond || iloop <= nstd || iloop <= nanticipate
         if use.anticipate
            % Mutlipliers of anticipated shocks.
            use.DyDea = time_domain.multiplierea(...
               use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
               use.lastcond,use.activeresid);
         end
      end
   end

   % Structural conditions.

   [y,w] = time_domain.simulatemean(...
      use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
      use.initmean,use.shock,nper,use.anticipate,use.deviation,[]);
   xf = w(1:nf,:);
   a = w(nf+1:end,:);
   [Py,Pfa,Pe] = time_domain.simulatemse(...
      use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec,...
      use.initmse,nper);

   % Store forecast with structural judgement.

   if use.dtrends
      func.mean{1}(:,2:end,iloop) = y + use.W;
   else
      func.mean{1}(:,2:end,iloop) = y;
   end
   func.mean{2}(:,2:end,iloop) = [xf;a];
   func.mean{2}(nf+1:end,1,iloop) = use.initmean;
   func.mean{3}(:,2:end,iloop) = use.shock;

   func.mse{1}(:,:,2:end,iloop) = Py;
   func.mse{2}(:,:,2:end,iloop) = Pfa;
   func.mse{2}(nf+1:end,nf+1:end,1,iloop) = use.initmse;
   func.mse{3}(:,:,2:end,iloop) = Pe;

   % Reduced-form conditions.

   if use.lastcond > 0 && nargout > 1

      % Conditional mean.

      Z1 = use.DyDa0(use.condindex,:);
      if use.anticipate
         Z2 = use.DyDea(use.condindex,:);
      else
         Z2 = use.DyDeu(use.condindex,:);
      end
      pe = use.cond(use.condindex) - y(use.condindex);
      % P = blkdiag([initmse,0;0,diag(stdvec.^2)]) = [P1;P2]
      % Z = [Z1,Z2];
      P1 = use.initmse(use.activeinit,use.activeinit);
      P2 = sparse(diag(use.stdvec(use.activeresid).^2));
      P_Zt = [ % P_Zt = P*transpose(Z);
         P1*transpose(Z1)
         P2*transpose(Z2)
      ];
      F = [Z1,Z2] * P_Zt;
      M = P_Zt / F;
      gamma = [ % gamma := [a(0);e(1);...;e(lastcond)] both active and inactive
         use.initmean
         vec(use.shock(:,1:use.lastcond))
      ]; 
      active = [use.activeinit,use.activeresid];
      gammahat = gamma;
      dgammahat = M * vec(pe); % only active entries
      gammahat(active) = gammahat(active) + dgammahat;

      % Simulate conditional mean with new init cond and new residuals.
      tmpinit = gammahat(1:nb);
      tmpshock = [reshape(gammahat(nb+1:end),[ne,use.lastcond]),use.shock(:,use.lastcond+1:end)];
      [yhat,what] = time_domain.simulatemean(...
         use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
         tmpinit,tmpshock,nper,use.anticipate,use.deviation,[]);
      xfhat = what(1:nf,:);
      ahat = what(nf+1:end,:);

      % Store conditional mean.

      if options.deviation
         fcon.mean{1}(:,2:end,iloop) = yhat;
      else
         fcon.mean{1}(:,2:end,iloop) = yhat + use.W;
      end
      fcon.mean{2}(:,2:end,iloop) = [xfhat;ahat];
      fcon.mean{2}(nf+1:end,1,iloop) = tmpinit;
      fcon.mean{3}(:,2:end,iloop) = tmpshock;

      % Conditional MSE.

      if options.anticipate
         Z2 = use.DyDeu(use.condindex,:);
         P1 = use.initmse(use.activeinit,use.activeinit);
         P2 = sparse(diag(use.stdvec(use.activeresid).^2));
         P_Zt = [
            P1*transpose(Z1)
            P2*transpose(Z2)
         ];
         F = [Z1,Z2] * P_Zt;
         M = P_Zt / F;
      end
      P = blkdiag(P1,P2);
      V = zeros(nb+ne*use.lastcond); % V = MSE gammahat, i.e. both active and inactive
      V(active,active) = P - M*transpose(P_Zt);

      % test statistic
      if nargout > 2
         Pi(iloop) = transpose(dgammahat) * blkdiag(pinv(P1),diag(1./(diag(P2)))) * dgammahat;
      end

      % MSE for y(t)
      % t = 1 .. lastcond
      X = [use.DyDa0,use.DyDeu];
      Vy = X*V(active,active)*transpose(X);

      % MSE for xf(t) and alpha(t)
      % t = 1 .. lastcond
      Vfa = use.DfaDa0eu*V(active,active)*transpose(use.DfaDa0eu);

      % MSE for e(t0
      % t = 1 .. lastcond
      Ve = V(nb+1:end,nb+1:end);

      % Project MSE.
      % t = lastcond+1 .. nper
      [Vy2,Vfa2,Ve2] = time_domain.simulatemse(...
         use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec(:,use.lastcond+1:end),...
         Vfa(end-nb+1:end,end-nb+1:end),nper-use.lastcond);

      % store conditional MSE

      for t = 1 : use.lastcond
         fcon.mse{1}(:,:,1+t,iloop) = Vy((t-1)*ny+(1:ny),(t-1)*ny+(1:ny));
         fcon.mse{2}(:,:,1+t,iloop) = Vfa((t-1)*nx+(1:nx),(t-1)*nx+(1:nx));
         fcon.mse{3}(:,:,1+t,iloop) = Ve((t-1)*ne+(1:ne),(t-1)*ne+(1:ne));
      end
      fcon.mse{2}(nf+1:end,nf+1:end,1,iloop) = V(1:nb,1:nb); % initial condition
      fcon.mse{1}(:,:,1+(use.lastcond+1:nper),iloop) = Vy2;
      fcon.mse{2}(:,:,1+(use.lastcond+1:nper),iloop) = Vfa2;
      fcon.mse{3}(:,:,1+(use.lastcond+1:nper),iloop) = Ve2;

   else

      if nargout > 1
         for i = 1 : 3
            fcon.mean{i}(:,:,iloop) = func.mean{i}(:,:,iloop);
            fcon.mse{i}(:,:,:,iloop) = func.mse{i}(:,:,:,iloop);
         end%for
      end%if

   end%if

end%for

%********************************************************************
%! Post-mortem.

% Fix negative diagonal entries.
for i = 1 : 3
   func.mse{i} = fixcov(func.mse{i});
   if nargout > 1
      fcon.mse{i} = fixcov(fcon.mse{i});
   end
end

if strcmp(options.output,'dbase')
  func.mean = dp2db(m,func.mean);
  func.std = dp2db(m,func.mse);
  if nargout > 1
     fcon.mean = dp2db(m,fcon.mean);
     fcon.std = dp2db(m,fcon.mse);
  end
end

% Underdetermined conditional forecast system.
if ~isempty(underdet)
   warning_(40,sprintf(' #%g',underdet));
end

% Expansion not avaiable.
if ~isempty(nansolution)
   warning_(44,sprintf(' #%g',nansolution));
end

% Expansion not available.
if ~isempty(nanexpand)
   warning_(45,sprintf(' #%g',nanexpand));
end

end
% End of primary function.