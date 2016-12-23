function [func,fcon,Pi] = forecast(T,R,K,Z,H,D,U,stdvec,initmean,initmse,shock,cond,anticipate,deviation)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.forecast">idoc model.forecast</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse the The IRIS Toolbox documentation found in the Contents pane.

% The IRIS Toolbox 2008/05/05.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body


%! range = range(1) : range(end);
%! [ny,nx,nf,nb,ne,np,nalt] = size_(m);
%! nper = length(range);%}
[ny,ne] = size(H);
[nx,nb] = size(T);
nf = nx - nb;
nper = size(shock,2);

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
lastcond = max([0,find(any(condindex,1),1,'last')]);
condindex = condindex(:,1:lastcond);
condindex = vech(condindex);

tolmse = getrealsmall('mse');
activeresid = vech(stdvec(:,1:lastcond) > 0);
activeinit = vech(abs(diag(initmse)) > tolmse);
   
% Time of last imposed shock.
lastshock = find(any(shock ~= 0),1,'last');
if isempty(lastshock)
   lastshock = 0;
end

% Time of farthest anticipated shock needed.
if anticipate
   last = max([lastshock,lastcond]);   
else
   last = 0;
end

if lastcond > 0
   [DyDa0,DyDeu,DfaDa0eu] = umultipliers_();
   if anticipate
      DyDea = amultipliers_();      
   end
end

% Unconditional forecast.

[y,xf,a] = uncmean(T,R,K,Z,H,D,U,initmean,shock,anticipate,deviation);
[Py,Pfa,Pe] = uncmse(T,R,K,Z,H,D,U,stdvec,initmse);

% Store unconditional forecast.

func.mean{1}(:,2:end) = y;
func.mean{2}(:,2:end) = [xf;a];
func.mean{2}(nf+1:end,1) = initmean;
func.mean{3}(:,2:end) = shock;

func.mse{1}(:,:,2:end) = Py;
func.mse{2}(:,:,2:end) = Pfa;
func.mse{2}(nf+1:end,nf+1:end,1) = initmse;
func.mse{3}(:,:,2:end) = Pe;

   % Conditional forecast.

   if lastcond > 0 && nargout > 1

      % Conditional mean.

      Z1 = DyDa0(condindex,:);
      if anticipate
         Z2 = DyDea(condindex,:);
      else
         Z2 = DyDeu(condindex,:);
      end
      pe = cond(condindex) - y(condindex);
      % P = blkdiag([initmse,0;0,diag(stdvec.^2)]) = [P1;P2]
      % Z = [Z1,Z2];
      P1 = initmse(activeinit,activeinit);
      P2 = sparse(diag(stdvec(activeresid).^2));
      P_Zt = [ % P_Zt = P*transpose(Z);
         P1*transpose(Z1)
         P2*transpose(Z2)
      ];
      F = [Z1,Z2] * P_Zt;
      M = P_Zt / F;
      gamma = [ % gamma := [a(0);e(1);...;e(lastcond)] both active and inactive
         initmean
         vec(shock(:,1:lastcond))
      ]; 
      active = [activeinit,activeresid];
      gammahat = gamma;
      dgammahat = M * vec(pe); % only active entries
      gammahat(active) = gammahat(active) + dgammahat;

      % simulate conditional mean with new init cond and new residuals
      tmpinit = gammahat(1:nb);
      tmpshock = [reshape(gammahat(nb+1:end),[ne,lastcond]),shock(:,lastcond+1:end)];
      [yhat,xfhat,ahat] = uncmean(T,R,K,Z,H,D,U,tmpinit,tmpshock,anticipate,deviation);

      % Store conditional mean.

      fcon.mean{1}(:,2:end) = yhat;
      fcon.mean{2}(:,2:end) = [xfhat;ahat];
      fcon.mean{2}(nf+1:end,1) = tmpinit;
      fcon.mean{3}(:,2:end) = tmpshock;

      % Conditional MSE.

      if anticipate
         Z2 = DyDeu(condindex,:);
         P1 = initmse(activeinit,activeinit);
         P2 = sparse(diag(stdvec(activeresid).^2));
         P_Zt = [
            P1*transpose(Z1)
            P2*transpose(Z2)
         ];
         F = [Z1,Z2] * P_Zt;
         M = P_Zt / F;
      end
      P = blkdiag(P1,P2);
      V = zeros(nb+ne*lastcond); % V = MSE gammahat,i.e. both active and inactive
      V(active,active) = P - M*transpose(P_Zt);

      % Test statistic.
      Pi = transpose(dgammahat) * blkdiag(pinv(P1),diag(1./(diag(P2)))) * dgammahat;

      % MSE for y(t)
      % t = 1 .. lastcond
      X = [DyDa0,DyDeu];
      Vy = X*V(active,active)*transpose(X);

      % MSE for xf(t) and alpha(t)
      % t = 1 .. lastcond
      Vfa = DfaDa0eu*V(active,active)*transpose(DfaDa0eu);

      % MSE for e(t0
      % t = 1 .. lastcond
      Ve = V(nb+1:end,nb+1:end);

      % project MSE
      % t = lastcond+1 .. nper
      [Vy2,Vfa2,Ve2] = uncmse(T,R,K,Z,H,D,U,stdvec(:,lastcond+1:end),Vfa(end-nb+1:end,end-nb+1:end));

      % Store conditional MSE.

      for t = 1 : lastcond
         fcon.mse{1}(:,:,1+t) = Vy((t-1)*ny+(1:ny),(t-1)*ny+(1:ny));
         fcon.mse{2}(:,:,1+t) = Vfa((t-1)*nx+(1:nx),(t-1)*nx+(1:nx));
         fcon.mse{3}(:,:,1+t) = Ve((t-1)*ne+(1:ne),(t-1)*ne+(1:ne));
      end
      fcon.mse{2}(nf+1:end,nf+1:end,1) = V(1:nb,1:nb);
      fcon.mse{1}(:,:,1+(lastcond+1:nper)) = Vy2;
      fcon.mse{2}(:,:,1+(lastcond+1:nper)) = Vfa2;
      fcon.mse{3}(:,:,1+(lastcond+1:nper)) = Ve2;

   elseif nargout > 1
   
      fcon.mean = func.mean;
      fcon.mse = func.mse;
      Pi = 0;

   end

% Fix negative diagonal entries in MSE matrices.
for i = 1 : 3
   func.mse{i} = fixcov(func.mse{i});
   if nargout > 1
      fcon.mse{i} = fixcov(fcon.mse{i});
   end
end

% cut off small variances/covariances
for i = 1 : 3
   func.mse{i}(abs(func.mse{i}) < tolmse) = 0;
   if nargout > 1
      fcon.mse{i}(abs(fcon.mse{i}) < tolmse) = 0;
   end
end

% end of function body

% ===========================================================================================================
%! nested function amultipliers_()

function DyDe = amultipliers_()
   % impact of active initial conditions and anticipated active shocks
   % DyDe = dy(t) / de(t)
   % t =1 .. lastcond
   Tb = T(nf+1:end,:);
   Rb = R(nf+1:end,1:lastcond*ne);
   DaDe = zeros([nb,lastcond*ne]);
   DyDe = zeros([lastcond*ny,lastcond*ne]);
   DaDe(:,:) = Rb;
   DyDe(1:ny,:) = Z*DaDe;
   DyDe(1:ny,1:ne) = DyDe(1:ny,1:ne) + H;
   for t = 2 : lastcond
      % impact on alpha vector
      DaDe(:,:) = T1*DaDe;
      DaDe(:,(t-1)*ne+1:end) = DaDe(:,(t-1)*ne+1:end) + Rb(:,1:end-(t-1)*ne);
      % impact on measurement variables
      DyDe((t-1)*ny+(1:ny),:) = Z*DaDe;
      DyDe((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) = DyDe((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) + H;
   end
   DyDe = DyDe(:,activeresid);
end
% end of nested function amultipliers_()

% ===========================================================================================================
%! nested function umultipliers_()

function [DyDa0,DyDe,DfaDa0e] = umultipliers_()
   % impact of active initial conditions and unanticipated active shocks
   % DaDb = da(t) / da(0)
   % DfDb = da(t) / da(0)
   % DyDb = dy(t) / da(0)
   % DaDe = da(t) / de(t)
   % DfDe = da(t) / de(t)
   % DyDe = dy(t) / de(t)
   % DfaDa0e = d [xf(1);a(1);xf(2);a(2);...] / d [a0;e(1);...;e(lastcond)]
   % t = 1 .. lastcond
   Tf = T(1:nf,:);
   Rf = R(1:nf,1:ne);
   Tb = T(nf+1:end,:);
   Rb = R(nf+1:end,1:ne);
   DaDa0 = zeros([lastcond*nb,nb]);
   DfDa0 = zeros([lastcond*nf,nb]);
   DbDa0 = zeros([lastcond*nb,nb]);
   DyDa0 = zeros([lastcond*ny,nb]);
   DaDe = zeros([lastcond*nb,lastcond*ne]);
   DfDe = zeros([lastcond*nf,lastcond*ne]);
   DbDe = zeros([lastcond*nb,lastcond*ne]);
   DyDe = zeros([lastcond*ny,lastcond*ne]);
   DaDa0(1:nb,:) = Tb;
   DfDa0(1:nf,:) = Tf;
   DyDa0(1:ny,:) = Z*DaDa0(1:nb,:);
   DaDe(1:nb,1:ne) = Rb;
   DfDe(1:nf,1:ne) = Rf;
   DyDe(1:ny,:) = Z*DaDe(1:nb,:);
   DyDe(1:ny,1:ne) = DyDe(1:ny,1:ne) + H;
   for i = 2 : lastcond
      % impact on alpha vector
      DaDa0((i-1)*nb+(1:nb),:) = Tb*DaDa0((i-2)*nb+(1:nb),:);
      DaDe((i-1)*nb+(1:nb),1:(i-1)*ne) = Tb*DaDe((i-2)*nb+(1:nb),1:(i-1)*ne);
      DaDe((i-1)*nb+(1:nb),(i-1)*ne+(1:ne)) = DaDe((i-1)*nb+(1:nb),(i-1)*ne+(1:ne)) + Rb;
      % impact on fwl variables
      DfDa0((i-1)*nf+(1:nf),:) = Tf*DaDa0((i-2)*nb+(1:nb),:);
      DfDe((i-1)*nf+(1:nf),1:(i-1)*ne) = Tf*DaDe((i-2)*nb+(1:nb),1:(i-1)*ne);
      DfDe((i-1)*nf+(1:nf),(i-1)*ne+(1:ne)) = DfDe((i-1)*nf+(1:nf),(i-1)*ne+(1:ne)) + Rf;
      % impact on measurement variables
      DyDa0((i-1)*ny+(1:ny),:) = Z*DaDa0((i-1)*nb+(1:nb),:);
      DyDe((i-1)*ny+(1:ny),1:i*ne) = Z*DaDe((i-1)*nb+(1:nb),1:i*ne);
      DyDe((i-1)*ny+(1:ny),(i-1)*ne+(1:ne)) = DyDe((i-1)*ny+(1:ny),(i-1)*ne+(1:ne)) + H;
   end
   DaDa0 = DaDa0(:,activeinit);
   DfDa0 = DfDa0(:,activeinit);
   DyDa0 = DyDa0(:,activeinit);
   DaDe = DaDe(:,activeresid);
   DfDe = DfDe(:,activeresid);
   DyDe = DyDe(:,activeresid);
   DfaDa0e = [];
   for t = 1 : lastcond
      DfaDa0e = [
         DfaDa0e
         DfDa0((t-1)*nf+(1:nf),:),DfDe((t-1)*nf+(1:nf),:)
         DaDa0((t-1)*nb+(1:nb),:),DaDe((t-1)*nb+(1:nb),:)
      ];
   end
end
% end of nested function umultipliers_()

end
% end of primary function