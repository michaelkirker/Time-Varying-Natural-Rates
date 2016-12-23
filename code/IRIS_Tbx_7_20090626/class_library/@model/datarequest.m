function varargout = datarequest(request,m,data,range)
% DATAREQUEST Request data from database or datapack.

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Convert plain dbase/dpack to struct with .mean and .mse.
if (isstruct(data) && ~isfield(data,'mean')) || iscell(data)
   tmpdata = data;
   data = struct();
   data.mean = tmpdata;
   data.mse = [];
end

[ny,nx,nf,nb,ne,np,nalt] = size(m);
if nargin < 4 && iscell(data.mean)
   range = Inf;
end

switch request
case 'init'
   if nargout < 3
      [initmean,naninit] = data2init_();
      varargout{1} = initmean;
      varargout{2} = naninit;
   else
      [initmean,naninit,initmse] = data2init_();
      varargout{1} = initmean;
      varargout{2} = naninit;   
      varargout{3} = initmse;
   end
case {'y','y*'} % Star means do not logarithmise.
   varargout{1} = data2y_();
case {'e','resid'}
   varargout{1} = data2e_();
case {'x0','x0*'} % Star means do not logarithmise.
   varargout{1} = data2x0_();
case 'alpha'
   varargout{1} = data2alpha_();
case 'range'
   if iscell(data.mean)
      varargout{1} = data.mean{4}(2:end);
   else
      varargout{1} = [];
   end
end

%********************************************************************
%! Nested function data2init_().

function [initmean,naninit,initmse] = data2init_()
   initmean = nan([nb,1,nalt]);
   initmse = [];
   naninit = {};
   if isstruct(data.mean)
      % Input data for mean is 'dbase'.
      realid = real(m.solutionid{2}(nf+1:end));
      imagid = imag(m.solutionid{2}(nf+1:end));
      x = db2array(data.mean,range(1)-1,m.name(realid),imagid,m.log(realid));    
      % Search required init conds for NaNs.
      naninit = false([nb,1]);
      for iloop = 1 : size(x,3)
         if iloop <= nalt
            required = vec(m.icondix(1,:,iloop));
         end
         naninit = naninit | (isnan(x(:,1,iloop)) & required);
      end
      % List of NaN init conds.
      naninit = m.name(realid(naninit));
      % Transform xb to alpha.
      [initmean,nanindex] = transform_('xb2alpha',x,m.solution{7});
   elseif iscell(data.mean)
      % Input data for mean is 'dpack'.
      if length(range) == 1 && isinf(range)
         index = 1;
      else
         index = round(range(1)-1 - data.mean{4}(1) + 1);
      end
      if index >= 1 && index <= length(data.mean{4})
         initmean = data.mean{2}(nf+1:end,index,:);
         if ~isempty(data.mse)
            initmse = data.mse{2}(nf+1:end,nf+1:end,index,:);         
         end
         % Recompute alpha mean and MSE if U matrices differ in dpack and model
         [initmean,initmse] = consistent_(initmean,initmse,data.mean{5}.U,m.solution{7});
      end
   end
   if isfield(data,'mse') && ~isempty(data.mse)
      % Input data for mse exist.
      if length(range) == 1 && isinf(range)
         index = 1;
      else
         index = round(range(1)-1 - data.mse{4}(1) + 1);
      end
      if index >= 1 && index <= length(data.mse{4})
         initmse = data.mse{2}(nf+1:end,nf+1:end,index,:);         
         % Recompute alpha mean and MSE
         % if U matrices differ in dpack and model.
         [initmean,initmse] = consistent_(initmean,initmse,data.mse{5}.U,m.solution{7});
      end      
   end
end
% End of nested function data2init_().

%********************************************************************
%! Nested function data2y_().
% Fetch observables.
% Do not log if requested as 'y*'.

function y = data2y_()
   if isstruct(data.mean)
      % Input format is 'dbase'.
      realid = real(m.solutionid{1});
      imagid = imag(m.solutionid{1});
      tmplog = m.log(realid);
      if strcmp(request(end),'*')
         tmplog(:) = false;
      end
      y = db2array(data.mean,range,m.name(realid),imagid,tmplog);
   else
      % Input format is 'dpack'.
      y = data.mean{1}(:,2:end,:);
   end
end
% End of nested function data2y_().

%********************************************************************
%! Nested function data2e_().
% Fetch residuals.
% Set NaN residuals to zero.

function e = data2e_()
   if isstruct(data.mean)
      % Input format is 'dbase'.
      realid = real(m.solutionid{3});
      imagid = imag(m.solutionid{3});
      e = db2array(data.mean,range,m.name(realid),imagid,m.log(realid));
   else
      % Input format is 'dpack'.
      e = data.mean{3}(:,2:end,:);
   end
   e(isnan(e)) = 0;
end
% End of nested function data2e_().

%********************************************************************
%! Nested function data2x0_().
% Fetch current dates of xf and xb variables.
% Set lags and leads to NaN.

function x0 = data2x0_()
   if isstruct(data.mean)
      % Input format is 'dbase'.
      % Fetch only time t variables.
      realid = real(m.solutionid{2});
      imagid = imag(m.solutionid{2});
      index = imagid == 0;
      realid = realid(index);
      imagid = imagid(index);
      tmplog = m.log(realid);
      if strcmp(request(end),'*')
         tmplog(:) = false;
      end
      x0(index,:,:) = db2array(data.mean,range,m.name(realid),imagid,tmplog);
      % Set lags and leads to NaN.
      x0(~index,:,:) = NaN;
   else
      % Input format is 'dpack'.
      x0 = data.mean{2}(:,2:end,:);
      % Transform alpha to xb.
      x0(nf+1:end,:,:) = transform_('alpha2xb',x0(nf+1:end,:,:),data.mean{5}.U);
      % Set lags and leads to NaN.
      [yname,xname,ename,ylog,xlog,xshift] = dpmeta(data.mean{5});
      index = xshift == 0;
      x0(~index,:,:) = NaN;
   end
end
% End of nested function data2x0_().

%********************************************************************
%! Nested function data2alpha_().

function alpha = data2alpha_()
   if isstruct(data.mean)
      realid = real(m.solutionid{2});
      imagid = imag(m.solutionid{2});
      realid = realid(nf+1:end);
      imagid = imagid(nf+1:end);
      alpha = db2array(data.mean,range,m.name(realid),imagid,m.log(realid));
      alpha = transform_('xb2alpha',alpha,m.solution{7});
   else
      alpha = data.mean{2}(nf+1:end,2:end,:);
   end
end

end
% End of primary function.

%********************************************************************
%! Subfunction transform_().
% Transform xb to alpha or alpha to xb.

function [x,nanindex] = transform_(request,x,U)

% Expand init conds in 3rd dim to match nalt.
nalt = size(U,3);
ndata = size(x,3);
nloop = max([ndata,nalt]);
if ndata < nloop
   x = x(:,:,[1:end,end*ones([1,nloop-ndata])]);
end

% Convert xb to alpha or alpha to xb.
% Check init conds for NaNs.
flag = strcmp(request,'xb2alpha');
nanindex = false([size(x,1),1]);
x(isnan(x)) = 0;
for iloop = 1 : nloop
   if iloop <= nalt
      Ui = U(:,:,iloop);
   end
   if flag
      x(:,:,iloop) = Ui \ x(:,:,iloop);
   else
      x(:,:,iloop) = Ui * x(:,:,iloop);
   end
end

end
% end of subfunction transform_()

%********************************************************************
%! Subfunction consistent_().
% Check if U matrices are identical in dpack and model.
% If not, recompute alpha so that it corresponds to model.

function [initmean,initmse] = consistent_(initmean,initmse,Udata,Umodel)

tol = getrealsmall();

if size(Udata,3) == size(Umodel,3) && maxabs(Udata-Umodel) <= tol
   return
end

ndata = size(initmean,3);
nloop = max([ndata,size(Udata,3),size(Umodel,3)]);
if size(initmean,3) < nloop
   initmean = initmean(:,1,[1:end,end*ones([1,nloop-ndata])]);
   initmse = initmse(:,:,1,[1:end,end*ones([1,nloop-ndata])]);
end

for iloop = 1 : nloop
   if iloop <= size(Udata,3)
      Udatai = Udata(:,:,iloop);
   end
   if iloop <= size(Umodel,3)
      Umodeli = Umodel(:,:,iloop);
   end
   % Convert dpack alpha to xb
   initmean(:,1,iloop) = Udatai * initmean(:,:,iloop);
   initmse(:,:,1,iloop) = Udatai * initmse(:,:,1,iloop) * transpose(Udatai);
   % Convert xb to model alpha
   initmean(:,1,iloop) = Umodeli \ initmean(:,:,iloop);
   initmse(:,:,1,iloop) = Umodeli \ initmse(:,:,1,iloop) / transpose(Umodeli);
end

end
% End of subfunction consistent_().