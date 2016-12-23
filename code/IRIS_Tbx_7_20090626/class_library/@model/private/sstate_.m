function  [m,flag] = sstate_(m,options)
% SSTATE  Find steady state.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if issparse(m.occur)
  m.occur = reshape(full(m.occur),[size(m.occur,1),length(m.name),size(m.occur,2)/length(m.name)]);
end

ny = sum(m.nametype == 1);
realsmall = getrealsmall();

% Fix steady state of desired variables.
fixed = false(size(m.name));
index = findnames(m.name(m.nametype <= 2),options.fix);
% Check for non-existing names.
tmp = isnan(index);
if any(tmp)
  warning_(25,options.fix(tmp));
  index(tmp) = [];
end
fixed(index) = true;
% Check if there are variables fixed to NaN.
nansstate = any(isnan(real(m.assign)),3) & fixed;
if any(nansstate)
  error_(43,m.name(nansstate));
end

nalt = size(m.assign,3);
flag = true([1,nalt]);

if m.linear
  [ans,index] = isnan(m,'solution');
  for ialt = find(~index)
    linear_();
  end
else
  [nameblk,eqtnblk] = getblk_();
  for ialt = 1 : nalt
    % Assign initial values.
    x = real(m.assign(1,:,ialt));
    x(m.nametype == 3) = 0;
    index = isnan(x);
    if any(index)
      if abs(options.randomise(1) - options.randomise(2)) <= realsmall
         x(index) = options.randomise(1);
      else
        x(index) = options.randomise(1) + rand([1,sum(index)])*(options.randomise(2)-options.randomise(1));
      end
    end
    x(m.log) = log(x(m.log));

    % assign growth rates
    dx = imag(m.assign(1,:,ialt));
    dx(m.nametype >= 3) = 0;
    dx(dx == 0 & m.log == true) = 1;
    dx(m.log) = log(dx(m.log));

    inaccurate = {};
    notAvailable = {};
    for i = 1 : length(nameblk)
      [x,flag_,inaccurate_,notAvailable_] = ...
         nonlinear_(m,x,dx,nameblk{i},eqtnblk{i},fixed,realsmall,options);
      inaccurate = [inaccurate,inaccurate_];
      notAvailable = [notAvailable,notAvailable_];
      flag(ialt) = flag(ialt) && flag_;
    end
    if ny > 0
      [x,flag_,inaccurate_,notAvailable_] = ...
         nonlinear_(m,x,dx,find(m.nametype == 1),find(m.eqtntype == 1),fixed,realsmall,options);
      inaccurate = [inaccurate,inaccurate_];
      notAvailable = [notAvailable,notAvailable_];
      flag(ialt) = flag(ialt) && flag_;
    end
    if ~isempty(notAvailable)
       warning_(53,notAvailable);
    end
    if ~isempty(inaccurate)
       warning_(3,inaccurate);
    end
    x(m.log) = exp(x(m.log));
    m.assign(1,m.nametype <= 2,ialt) = complex(x(m.nametype <= 2),imag(m.assign(1,m.nametype <= 2,ialt)));
  end % ialt
end

m.occur = sparse(m.occur(:,:));

% End of function body.

%********************************************************************
%! Nested function getblk_().

   function [nameblk,eqtnblk] = getblk_()
      if ~options.blocks
         nameblk = {find(m.nametype == 2)};
         eqtnblk = {find(m.eqtntype == 2)};
         return
      end
      oc = any(m.occur(m.eqtnorder,m.nameorder,1:end),3);
      nameblk = cell([1,0]);
      eqtnblk = cell([1,0]);
      nameblk_ = zeros([1,0]);
      eqtnblk_ = zeros([1,0]);
      tmp = find(m.nametype == 2);
      for i = tmp(end:-1:1)
         nameblk_(end+1) = m.nameorder(i);
         eqtnblk_(end+1) = m.eqtnorder(i);
         if ~any(any(oc(i:end,ny+1:i-1)))
            nameblk{end+1} = nameblk_;
            eqtnblk{end+1} = eqtnblk_;
            nameblk_ = zeros([1,0]);
            eqtnblk_ = zeros([1,0]);
         end
      end
   end  
% End of nested function getblk_().

%********************************************************************
%! Nested function linear_().

  function assign = linear_() 
     T = m.solution{1}(:,:,ialt);
     K = m.solution{3}(:,:,ialt);
     Z = m.solution{4}(:,:,ialt);
     D = m.solution{6}(:,:,ialt);
     U = m.solution{7}(:,:,ialt);
     [nx,nb] = size(T);
     nunit = sum(abs(abs(m.eigval(1,:,ialt))-1) <= realsmall);
     nf = nx - nb;
     nstable = nb - nunit;
     Tf = T(1:nf,:);
     Ta = T(nf+1:end,:);
     Kf = K(1:nf,1);
     Ka = K(nf+1:end,1);
     if any(any(abs(Ta(1:nunit,1:nunit) - eye(nunit)) > realsmall))
        error_(32);
     end
     a2 = (eye(nstable) - Ta(nunit+1:end,nunit+1:end)) \ Ka(nunit+1:end,1);
     da1 = Ta(1:nunit,nunit+1:end)*a2 + Ka(1:nunit,1);
     x = [Tf*[-da1;a2]+Kf;U(:,nunit+1:end)*a2];
     dx = [Tf(:,1:nunit)*da1;U(:,1:nunit)*da1];
     x(abs(x) <= realsmall) = 0;
     dx(abs(dx) <= realsmall) = 0;
     id = m.solutionid{2};
     index = imag(id) == 0;
     id(~index) = [];
     x(~index) = [];
     dx(~index) = [];
     m.assign(1,real(id),ialt) = complex(vech(x),vech(dx));
     if ny > 0
        y = Z(:,nunit+1:end)*a2 + D;
        dy = Z(:,1:nunit)*da1;
        m.assign(1,real(m.solutionid{1}),ialt) = vech(complex(y,dy));
     end
  end
% End of nested function linear_().

end
% End of primary function.

%********************************************************************
%! Subfunction nonlinear_().

function [x,flag_,inaccurate_,notAvailable_] = ...
   nonlinear_(m,x,dx,nameblk,eqtnblk,fixed,realsmall,options)

   flag_ = true;
   inaccurate_ = {};
   notAvailable_ = {};
   
   % Return immediately if all variables are fixed in this block.
   if all(fixed(nameblk))
      return
   end
   
   % Drop fixed variables from the list.
   nameblk(fixed(nameblk)) = [];

   % delete and create temporaray files: sstateeval_.m and sstateeval_.p
   deletetmp_();
   fncode = file2char('private/sstateeval_.template');
   fncode = strrep(fncode,'$',[m.eqtnS{eqtnblk}]);
   char2file(fncode,'sstateeval_.m');
   rehash path;
   pcode('sstateeval_.m');
   rehash('path');

   % Call sstateeval_ to test for NaN and Inf.
   check = sstateeval_(x(nameblk),x,nameblk,dx);
   index = isnan(check) | isinf(check);
   if any(index)
      error_(7,m.eqtn(eqtnblk(index)));
   end

   % Call Optimization Tbx.
   switch lower(options.algorithm)
   case 'lsqnonlin'
      [X,resnorm,residual] = ...
         lsqnonlin(@sstateeval_,x(nameblk),[],[],options.optimset,x,nameblk,dx);
      exitflag = all(abs(residual) <= realsmall);
   case 'fsolve'
      [X,fval,exitflag] = fsolve(@sstateeval_,x(nameblk),options.optimset,x,nameblk,dx);
   end
   
   % Assign steady state to output variable.
   x(nameblk) = X;
   
   % Delete temporaray files |sstateeval_.m| and |sstateeval_.p|.
   deletetmp_();

   % Report NaNs.
   nanIndex = isnan(X);
   if any(nanIndex)
      flag_ = false;
      notAvailable_ = m.name(nameblk(nanIndex));
   end

   % Report inaccuracy.
   if exitflag <= 0 && any(~nanIndex)
      flag_ = false;
      inaccurate_ = m.name(nameblk(~nanIndex));
   end

   x(abs(x) < realsmall) = 0;

   function deletetmp_()
      status = warning('query','all');
      warning('off','MATLAB:DELETE:FileNotFound');
      delete('sstateeval_.m');
      delete('sstateeval_.p');
      warning(status);
      rehash('path');
   end

end
% End of subfunction nonlinear_().
