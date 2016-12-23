function [unc,con] = forecast(w,source,range,j,varargin)
% <a href="matlab: edit rvar/simulate">SIMULATE</a>  Simulate RVAR model.
%
% Syntax:
%   [unc,con] = simulate(w,source,range,j,...)

% The IRIS Toolbox 2009/03/30.
% Copyright 2007 Jaromir Benes.

[ny,p,nalt] = size(w);

default = {
   'deviation',false,@islogical,...
   'include',true,@islogical,...
};
options = passvalopt(default,varargin{1:end});

if ~any(size(source,2) == [2*ny,ny])
   error_(16);
end

%********************************************************************
%! Function body.

sourcerange = get(source{:,1:ny,:},'min');

if any(isinf(range))  
   range = sourcerange(1+p:end);
else
   range = range(1) : range(end);
end
nper = length(range);

% Empty forecast horizon.
if nper == 0 || isempty(sourcerange)
   tmp = tseries();
   unc.mean = replace(tmp,zeros([0,nx,ndata])); 
   unc.mse = replace(tmp,zeros([0,nx,nx,ndata]));
   con.mean = replace(tmp,zeros([0,nx,ndata])); 
   con.mse = replace(tmp,zeros([0,nx,nx,ndata]));
   return
end

% Get conditions.
if isempty(j)
   cond = nan([p+nper,ny]);
   shock = zeros([p+nper,ny]);
else
   cond = rangedata(j,range(1)-p:range(end));
   ncond = size(cond,3);
   if size(cond,2) == 2*ny
      shock = cond(:,ny+1:2*ny,:);
      shock(isnan(shock)) = 0;   
      cond = cond(:,1:ny,:);
   else
      shock = [];
   end
end

ndeviation = length(options.deviation(:));

% Get input data.
y = rangedata(source,range(1)-p:range(end));
if size(y,2) == 2*ny
   e = y(:,ny+1:end,:);
   e(isnan(e)) = 0;
   y = y(:,1:ny,:);
else
   e = zeros(size(y));
end
ndata = size(y,3);

% Sum up shocks in source and cond.
if ~isempty(shock)
   if ncond < ndata
      shock = cat(3,shock,shock(:,:,end*ones([1,ndata-ncond])));
   end
   if ndata < ncond
      e = cat(3,e,e(:,:,end*ones([1,ncond-ndata])));
   end
   e = e + shock;
end
e(1:p,:,:) = NaN;
nshock = size(e,3);

nloop = max([nalt,ndata,ncond,nshock,ndeviation]);

% Expand input data in 3rd dimension.
if ndata < nloop
   y = cat(3,y,y(:,:,end*ones([1,nloop-ndata])));
end

% Expand shocks in 3rd dimension.
if nshock < nloop
   e = cat(3,e,e(:,:,end*ones([1,nloop-nshock])));
end

% Transpose data arrays.
y = permute(y,[2,1,3]);
e = permute(e,[2,1,3]);
cond = permute(cond,[2,1,3]);
yhat = y;
ehat = e;

% Allocate MSE matrices.
Py = zeros([ny,ny,p+nper,nloop]);
Pe = Py;
if nargout >1
  Vy = Py;
  Ve = Py;
end

use = struct();
for iloop = 1 : nloop

   if iloop <= ndeviation
      use.deviation = options.deviation(iloop);
   end

   if iloop <= nalt
      % Cast VAR in general state space.
      use.T = companion(w,iloop);
      use.K = [w.K(:,iloop);zeros([ny*(p-1),1])];
      use.Z = sparse(eye([ny,ny*p]));
      use.H = sparse(zeros(ny));
      use.D = sparse(zeros([ny,1]));
      use.U = [];
      use.Omega = w.Omega(:,:,iloop);
      if isempty(w.B)
         % Reduced-form VAR.
         % Use Choleski to decompose Omega.
         use.R = transpose(chol(w.Omega(:,:,iloop)));
         use.R = [use.R;zeros([ny*(p-1),ny])];
         use.stdvec = ones([ny,nper]);
      else
         % Structural VAR.
         use.R = w.B(:,:,iloop);
         use.R = [use.R;zeros([ny*(p-1),ny])];         
         use.stdvec = w.std(iloop)*ones([ny,nper]);
      end
   end

   if p == 0
      use.initmean = zeros([ny,1]);
   else
      use.initmean = vec(y(:,p:-1:1,iloop));
   end
   use.initmse = sparse(zeros(p*ny));
   
   if iloop <= ncond
      use.cond = cond(:,p+1:end,iloop);
      % Potentially reduced-form shocks.
      use.e = e(:,p+1:end,iloop);
   end
   
   if iloop <= ncond || iloop <= nalt
      if isempty(w.B)
         % Convert reduced-form shocks to structural shocks.
         use.shock = use.R(1:ny,:) \ use.e;
      else
         use.shock = use.e;
      end
   end

   % Call state space forecast_ adapted to VARs.
   if nargout == 1
      tmpunc = ...
         forecast_(use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec,...
         use.initmean,use.shock,use.cond,use.deviation);
   else
      [tmpunc,tmpcon] = ...
         forecast_(use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.stdvec,...
         use.initmean,use.shock,use.cond,use.deviation);
   end

   % Capture output data.   
   y(:,p+1:end,iloop) = tmpunc.mean{1}(:,2:end);
   Py(:,:,p+1:end,iloop) = tmpunc.mse{1}(:,:,2:end);
   if isempty(w.B)
      Pe(:,:,p+1:end,iloop) = use.Omega(:,:,ones([1,nper]));
   else
      tmpomega = diag(stdvec(:,1).^2);
      Pe(:,:,p+1:end,iloop) = tmpomega(:,:,ones([1,nper]));
   end
   if nargout > 1
      yhat(:,p+1:end,iloop) = tmpcon.mean{1}(:,2:end);
      ehat(:,p+1:end,iloop) = tmpcon.mean{3}(:,2:end);
      Vy(:,:,p+1:end,iloop) = tmpcon.mse{1}(:,:,2:end);
      Ve(:,:,p+1:end,iloop) = tmpcon.mse{3}(:,:,2:end);
      if isempty(w.B)
         ehat(:,p+1:end,iloop) = use.R(1:ny,:)*ehat(:,p+1:end,iloop);
         for t = p + (1 : nper)
            Ve(:,:,t,iloop) = use.R(1:ny,:)*Ve(:,:,t,iloop)*transpose(use.R(1:ny,:));
         end
      end
   end
      
end

% Output time series.
template = tseries();
unc.mean = replace(template,[permute(y,[2,1,3]),permute(e,[2,1,3])],range(1)-p);
unc.mse = Py;
tmpstd = nan([nper+p,ny,nloop]);
for i = 1 : ny
   tmpstd(:,i,:) = sqrt(permute(Py(i,i,:,:),[3,1,4,2]));
end
unc.std = replace(template,tmpstd,range(1)-p);

if nargout > 1
   con.mean = replace(template,[permute(yhat,[2,1,3]),permute(ehat,[2,1,3])],range(1)-p);
   con.mse = Vy;
   tmpstd = nan([nper+p,ny,nloop]);
   for i = 1 : ny
      tmpstd(:,i,:) = sqrt(permute(Vy(i,i,:,:),[3,1,4,2]));
   end
   con.std = replace(template,tmpstd,range(1)-p);
end

end
% End of primary function.





%********************************************************************
%! Subfunction forecast_().

function [func,fcon] = forecast_(T,R,K,Z,H,D,U,stdvec,a0,e,cond,deviation)

[ny,ne] = size(H);
[nx,nx] = size(T);
nper = size(e,2);

% convert cond into array with measurement variables
% and structural shocks
%! shock = datarequest('e',m,cond,range);
%! cond = datarequest('y',m,cond,range);

%! Omega versus stdvec !!!
% get std deviations of shocks
%! stdvec = stdvec_(m,options.std,range);

% Pre-allocate output data.
func = struct();
func.mean = {nan([ny,1+nper]),nan([nx,1+nper]),nan([ne,1+nper])};
func.mse = {nan([ny,ny,1+nper]),nan([nx,nx,1+nper]),nan([ne,ne,1+nper])};
if nargout > 1
   fcon = func;
end

condindex = ~isnan(cond);
last = max([0,find(any(condindex,1),1,'last')]);
condindex = condindex(:,1:last);
condindex = vech(condindex);
active = vech(stdvec(:,1:last) > 0);

if last > 0
   [DyDeu,DaDeu] = time_domain.multipliereu(T,R,K,Z,H,D,U,last,active);
end

% Unconditional forecast.
[y,a] = time_domain.simulatemean(T,R,K,Z,H,D,U,a0,e,nper,false,deviation,[]);
[Py,Pa,Pe] = time_domain.simulatemse(T,R,K,Z,H,D,U,stdvec,[],nper);

% Store unconditional forecast.
% Mean vectors.
func.mean{1}(:,2:end) = y;
func.mean{2}(:,2:end) = a;
func.mean{2}(:,1) = a0;
func.mean{3}(:,2:end) = e;
% MSE matrices.
func.mse{1}(:,:,2:end) = Py;
func.mse{2}(:,:,2:end) = Pa;
func.mse{3}(:,:,2:end) = Pe;
% Initial MSE matrix.
func.mse{2}(:,:,1) = 0;

% Fix negative variances in MSE matrices.
for i = 1 : 3
   func.mse{i} = time_domain.fixcov(func.mse{i});
end

   % Conditional forecast.

   if last > 0 && nargout > 1

      % Conditional mean.
      Z1 = DyDeu(condindex,:);
      pe = cond(condindex) - y(condindex);
      P = sparse(diag(stdvec(active).^2));
      P_Z1t = P*transpose(Z1);
      F = Z1 * P_Z1t;
      M = P_Z1t / F;
      gammahat = vec(e(:,1:last)); % Active and inactive shocks.
      gammahat(active) = gammahat(active) + M*vec(pe);

      % Simulate conditional mean with new init cond and new
      % residuals.
      ehat = [reshape(gammahat,[ne,last]),e(:,last+1:end)];
      [yhat,ahat] = time_domain.simulatemean(T,R,K,Z,H,D,U,a0,ehat,nper,false,deviation,[]);

      % Store conditional mean.

      fcon.mean{1}(:,2:end) = yhat;
      fcon.mean{2}(:,2:end) = ahat;
      fcon.mean{2}(:,1) = a0;
      fcon.mean{3}(:,2:end) = ehat;

      % Conditional MSE.

      % MSE for e(t), y(t), a(t)
      % t = 1 ..last
      Ve = zeros(ne*last);
      Ve(active,active) = P - M*transpose(P_Z1t);
      Vy = DyDeu*Ve(active,active)*transpose(DyDeu);
      Va = DaDeu*Ve(active,active)*transpose(DaDeu);

      % Project MSEs beyond last
      % t = last+1 .. nper
      [Vy2,Va2,Ve2] = time_domain.simulatemse(...
         T,R,K,Z,H,D,U,stdvec(:,last+1:end),...
         Va(end-nx+1:end,end-nx+1:end),nper-last);

      % Store conditional MSE.

      for t = 1 : last
         fcon.mse{1}(:,:,1+t) = Vy((t-1)*ny+(1:ny),(t-1)*ny+(1:ny));
         fcon.mse{2}(:,:,1+t) = Va((t-1)*nx+(1:nx),(t-1)*nx+(1:nx));
         fcon.mse{3}(:,:,1+t) = Ve((t-1)*ne+(1:ne),(t-1)*ne+(1:ne));
      end
      fcon.mse{1}(:,:,1+(last+1:nper)) = Vy2;
      fcon.mse{2}(:,:,1+(last+1:nper)) = Va2;
      fcon.mse{3}(:,:,1+(last+1:nper)) = Ve2;
      % Initial MSE.
      fcon.mse{2}(:,:,1) = 0;

      % Fix negative variances in MSE matrices.
      for i = 1 : 3
         fcon.mse{i} = time_domain.fixcov(fcon.mse{i});
      end

   elseif nargout > 1

      fcon = func;

   end

end
% End of subfunction forecast_().