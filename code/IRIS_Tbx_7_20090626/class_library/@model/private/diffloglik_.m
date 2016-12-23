function [mloglik,Score,Info,se2] = diffloglik_(m,data,range,plist,pindex,options,logliktoptions)
% DIFFLOGLIK_  Low level for computing time-domain information matrix.

% The IRIS Toolbox 2009/02/13.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);

np = length(pindex);
[ans,nper,ndata] = size(data);

mloglik = zeros([1,ndata]);
Score = zeros([1,np,ndata]);
Info = zeros([np,np,ndata]);
se2 = zeros([1,ndata]);
p = m.assign(1,pindex);
step = max([abs(p);ones(size(p))],[],1)*eps()^(options.epspower);
pp = p + step;
mp = p - step;
twosteps = pp - mp;

% Create all parameterisations.
m(1:2*np+1) = m;
for i = 1 : np
   mindex = 1 + 2*(i-1) + 1;
   [m(mindex),npath] = updatemodel_(m(mindex),pp(i),pindex(i),options);
   if npath ~= 1
      failed(m,npath,'diffloglik');
   end   
   mindex = 1 + 2*(i-1) + 2;
   m(mindex) = updatemodel_(m(mindex),mp(i),pindex(i),options);
   if npath ~= 1
      failed(m,npath,'diffloglik');
   end   
end   

%********************************************************************
% Main loop.

ppedind = cell([1,np]);
ppedind(:) = {struct()};
mpedind = ppedind;

for idata = 1 : ndata

   report_();
   
   dpe = cell([1,np]);
   dpe(:) = {nan([ny,nper])};

   Fi_pe = zeros([ny,nper]);
   X = zeros(ny);

   Fi_dpe = cell([1,np]);
   Fi_dpe(1:np) = {nan([ny,nper])};

   dF = cell([1,np]);
   dF(:) = {nan([ny,ny,nper])};

   dFvec = cell([1,np]);   
   dFvec(:) = {[]};

   Fi_dF = cell([1,np]);
   Fi_dF(:) = {nan([ny,ny,nper])};
   
   if idata == 1
      [mloglik(idata),se2(idata),F,pe,ans,ans,pedind] = loglikt2_(m(1),data(:,:,idata),range,[],logliktoptions);
   else
      [mloglik(idata),se2(idata),F,pe] = loglikt2_(m(1),data(:,:,idata),range,pedind,logliktoptions);
   end
   Fi = F{2};
   F = F{1};
   for i = 1 : np
      if idata == 1
         [ans,ans,pF,ppe,ans,ans,ppedind{i}] = loglikt2_(m(1+2*(i-1)+1),data(:,:,idata),range,[],logliktoptions);
         [ans,ans,mF,mpe,ans,ans,mpedind{i}] = loglikt2_(m(1+2*(i-1)+2),data(:,:,idata),range,[],logliktoptions);
      else
         [ans,ans,pF,ppe] = loglikt2_(m(1+2*(i-1)+1),data(:,:,idata),range,ppedind{i},logliktoptions);
         [ans,ans,mF,mpe] = loglikt2_(m(1+2*(i-1)+2),data(:,:,idata),range,mpedind{i},logliktoptions);
      end
      dF{i}(:,:,:) = (pF{1} - mF{1}) / twosteps(i);
      dpe{i}(:,:) = (ppe - mpe) / twosteps(i);      
   end
   
   for t = 1 : nper
      o = ~isnan(pe(:,t));
      for i = 1 : np
         Fi_dF{i}(o,o,t) = Fi(o,o,t)*dF{i}(o,o,t);
      end
   end
   
   for t = 1 : nper
      o = ~isnan(pe(:,t));
      for i = 1 : np
         dFvec{t}(:,i) = vec(dF{i}(o,o,t));
         for j = 1 : i
            % Info(i,j,idata) = Info(i,j,idata) + 0.5*trace(Fi_dF{i}(o,o,t)*Fi_dF{j}(o,o,t)) + (transpose(dpe{i}(o,t))*Fi_dpe{j}(o,t));
            % first term is data independent
            % trace A*B = vech(A')*vec(B)
            Xi = transpose(Fi_dF{i}(o,o,t));
            Xi = transpose(Xi(:));
            Xj = Fi_dF{j}(o,o,t);
            Xj = Xj(:);
            Info(i,j,idata) = Info(i,j,idata) + Xi*Xj/2;
         end
      end
   end

   % Score vector.
   for t = 1 : nper
      o = ~isnan(pe(:,t));
      Fi_pe(o,t) = Fi(o,o,t)*pe(o,t);
      X(o,o,t) = eye(sum(o)) - Fi_pe(o,t)*transpose(pe(o,t));
      dpevec = [];
      for i = 1 : np
         dpevec = [dpevec,dpe{i}(o,t)];
         Fi_dpe{i}(o,t) = Fi(o,o,t)*dpe{i}(o,t);
      end
      Score(1,:,idata) = Score(1,:,idata) ...
         + vech(Fi(o,o,t)*transpose(X(o,o,t)))*dFvec{t}/2 + transpose(Fi_pe(o,t))*dpevec;
   end

   % Information matrix.
   for t = 1 : nper
      o = ~isnan(pe(:,t));
      for i = 1 : np
         for j = 1 : i
            % Info(i,j,idata) = Info(i,j,idata) + 0.5*trace(Fi_dF{i}(o,o,t)*Fi_dF{j}(o,o,t)) + (transpose(dpe{i}(o,t))*Fi_dpe{j}(o,t));
            % first term is data-independent and has been pre-computed
            Info(i,j,idata) = Info(i,j,idata) + (transpose(dpe{i}(o,t))*Fi_dpe{j}(o,t));
         end
      end
   end

   Info(:,:,idata) = Info(:,:,idata) + transpose(tril(Info(:,:,idata),-1));

end
% End of function body.





%********************************************************************
%! Nested function report_().
   function report_()
      if ~options.display
         return
      end
      disp(sprintf('Now processing data set %5g of %5g.',idata,ndata));
   end
% End of nested function report_().





end
% End of primary function.