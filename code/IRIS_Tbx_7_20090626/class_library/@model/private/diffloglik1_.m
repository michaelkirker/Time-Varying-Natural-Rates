function [mloglik,Score,Info,Se2] = diffloglik_(m,data,range,plist,pindex,varargin)
%
% MODEL/PRIVATE/DIFFLOGLIK_
%
% The IRIS Toolbox 2007/08/01. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

default = {...
  'deviation',false,...
  'display',false,...
  'exclude',{},...
  'epspower',1/3,...
  'relative',true,...
  'solve',true,...
  'sstate',[],...
};
options = passopt(default,varargin{:});
logliktoptions = {'deviation',options.deviation,'exclude',options.exclude,'relative',options.relative};

% ===========================================================================================================
%% function body

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

np = length(pindex);
[ans,nper,ndata] = size(data);

p = m.assign(1,pindex);

mloglik = zeros([1,ndata]);
Score = zeros([1,np,ndata]);
Info = zeros([np,np,ndata]);
Se2 = nan([1,ndata]);
step = max([abs(p);ones(size(p))],[],1)*eps()^(options.epspower);
twosteps = nan(size(step));
mm = cell([1,np]);
pm = cell([1,np]);
pF = cell([1,np]);
ppe = cell([1,np]);
mF = cell([1,np]);
mpe = cell([1,np]);

% Run Kalman on first data set to get data-independent filter matrices.
y = data(:,:,1);
[mloglik(1),se2(1),F,pe,ans,ans,setup] = loglikt_(m,y,range,[],logliktoptions{:});
iF = F{2};
F = F{1}; 

% P is used when steady state requested.
if ~isempty(options.sstate)
  P = cell2struct(num2cell(m.assign),m.name,2);
end

for i = 1 : np
  % Increase i-th parameter by step.
  ppstep = p(i) + step(i);
  pm{i} = m;
  pm{i}.assign(1,pindex(i)) = ppstep;
  if ~isempty(options.sstate)
    P.(plist{i}) = ppstep;
    pm{i} = assign(pm{i},options.sstate(P));
  end
  if options.solve
     pm{i} = solve(pm{i});
  end
  [ans,ans,pF{i},ppe{i},ans,ans,psetup{i}] = loglikt_(pm{i},y,range,[],logliktoptions{:});
  pF{i} = pF{i}{1};
  pmstep = p(i) - step(i);
  % Reduce i-th parameter by step.
  mm{i} = m;
  mm{i}.assign(1,pindex(i)) = pmstep;
  if ~isempty(options.sstate)
    P.(plist{i}) = pmstep;
    mm{i} = assign(mm{i},options.sstate(P));
  end
  if options.solve
     mm{i} = solve(mm{i});
  end
  [ans,ans,mF{i},mpe{i},ans,ans,msetup{i}] = loglikt_(mm{i},y,range,[],logliktoptions{:});
  mF{i} = mF{i}{1};
  twosteps(i) = ppstep - pmstep;
  % Reset i-th parameter to its value in database used for steady state.
  P.plist{i} = p(i);
end

for idata = 1 : ndata

   % Pre-allocate cell arrays.
   dFvec = cell([1,nper]);
   dpe = cell([1,np]);
   F_dF = cell([1,np]);
   F_dpe = cell([1,np]);
   
   % Pre-allocate matrices.
   F_pe = nan([ny,1]);

   report_();
   y = data(:,:,idata);
   ixy = ~isnan(y);
   if idata > 1
      [mloglik(idata),se2(idata),F,pe] = loglikt_(m,y,range,setup,logliktoptions{:});
      iF = F{2};
      F = F{1}; 
   end
  
   for t = 1 : nper
      % Compute and store F\pe
      ixy = ~isnan(y(:,t));
      F_pe(ixy,t) = iF(ixy,ixy,t)*pe(ixy,t);
   end
   
   if idata > 1
      for i = 1 : np
         % Compute pF, mF, dF, ppe, mpe for each parameter.
         [ans,ans,pF{i},ppe{i}] = loglikt_(pm{i},y,range,psetup{i},logliktoptions{:});
         pF{i} = pF{i}{1};
         [ans,ans,mF{i},mpe{i}] = loglikt_(mm{i},y,range,msetup{i},logliktoptions{:});
         mF{i} = mF{i}{1};
      end
   end
   
   for i = 1 : np
      dF = (pF{i} - mF{i}) / twosteps(i);
      % Compute and store F\dF, vec(dF), and dpe for each parameter.
      for t = 1 : nper
         ixy = ~isnan(y(:,t));
         F_dF{i}(ixy,ixy,t) = iF(ixy,ixy,t) * dF(ixy,ixy,t);
         dFvec{t}(:,i) = vec(dF(ixy,ixy,t));
      end      
      dpe{i} = (ppe{i} - mpe{i}) / twosteps(i);
   end   

   % Score vector
   for t = 1 : nper
      ixy = ~isnan(y(:,t));
      X(ixy,ixy,t) = eye(sum(ixy)) - F_pe(ixy,t)*transpose(pe(ixy,t));
      dpevec = [];
      for i = 1 : np
         dpevec = [dpevec,dpe{i}(ixy,t)];
         F_dpe{i}(ixy,t) = iF(ixy,ixy,t)*dpe{i}(ixy,t);
      end
      Score(1,:,idata) = Score(1,:,idata) + vech(iF(ixy,ixy,t)*transpose(X(ixy,ixy,t)))*dFvec{t}/2 + transpose(F_pe(ixy,t))*dpevec;
   end

   % Information matrix Part I.
   for t = 1 : nper
      ixy = ~isnan(y(:,t));
      for i = 1 : np
         for j = 1 : i
            % Info(i,j,idata) = Info(i,j,idata) + 0.5*trace(F_dF{i}(ixy,ixy,t)*F_dF{j}(ixy,ixy,t)) + (transpose(dpe{i}(ixy,t))*F_dpe{j}(ixy,t));
            % first term is data independent
            % trace A*B = vech(A')*vec(B)
            Xi = transpose(F_dF{i}(ixy,ixy,t));
            Xi = transpose(Xi(:));
            Xj = F_dF{j}(ixy,ixy,t);
            Xj = Xj(:);
            Info(i,j,idata) = Info(i,j,idata) + Xi*Xj/2;
         end
      end
   end
   global I1;
   I1 = Info;
   
   % Information matrix Part II.
   for t = 1 : nper
      ixy = ~isnan(y(:,t));
      for i = 1 : np
         for j = 1 : i
            % Info(i,j,idata) = Info(i,j,idata) + 0.5*trace(F_dF{i}(ixy,ixy,t)*F_dF{j}(ixy,ixy,t)) + (transpose(dpe{i}(ixy,t))*F_dpe{j}(ixy,t));
            % first term is data-independent and has been pre-computed
            Info(i,j,idata) = Info(i,j,idata) + (transpose(dpe{i}(ixy,t))*F_dpe{j}(ixy,t));
         end
      end
   end
   Info(:,:,idata) = Info(:,:,idata) + transpose(tril(Info(:,:,idata),-1));

end

% end of function body

% ===========================================================================================================
%% nested function report_()

function report_()
   if ~options.display
      return
   end%if
	disp(sprintf('Data set processed: %5g of %5g.',idata,ndata));
end
% end of nested function

end
% end of primary function