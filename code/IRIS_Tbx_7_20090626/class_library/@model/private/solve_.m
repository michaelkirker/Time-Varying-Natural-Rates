function [m,npath] = solve_(m,forward,tolerance,alt,select,usersystem)
% First-order accurate quasi-triangular state-space form.

% The IRIS Toolbox 2009/02/12.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

ny = length(m.systemid{1});
nx = length(m.systemid{2});
nb = sum(imag(m.systemid{2}) < 0);
nf = nx - nb;
ne = length(m.systemid{3});
fkeep = ~m.metadelete;
nfkeep = sum(fkeep);
nalt = size(m.assign,3);

if islogical(alt)
   alt = find(alt);
elseif isnumeric(alt) && any(isinf(alt))
   alt = 1 : nalt;
end

allocsolution_();
npath = nan([1,nalt]);

for ialt = alt(:)'
   if isempty(usersystem)
      eqselect = eqselect_(m,ialt,select);
      eqselect(m.eqtntype >= 3) = false;
      [m,deriv] = deriv_(m,eqselect,ialt);
      [m,system] = system_(m,deriv,eqselect,ialt);
   else
      system = usersystem;
   end   
   % Check system matrices for complex numbers.
   if ~isreal(system.K{1}) || ~isreal(system.K{2}) || ~isreal(system.A{1}) || ~isreal(system.A{2}) || ~isreal(system.B{1}) || ~isreal(system.B{2}) || ~isreal(system.E{1}) || ~isreal(system.E{2})
      npath(ialt) = 1i;
      continue;
   end
   % Check system matrices for NaNs.
   if any(isnan(system.K{1})) || any(isnan(system.K{2})) || any(any(isnan(system.A{1}))) || any(any(isnan(system.A{2}))) || any(any(isnan(system.B{1}))) || any(any(isnan(system.B{2}))) || any(any(isnan(system.E{1}))) || any(any(isnan(system.E{2})))
      npath(ialt) = NaN;
      continue;
   end
   [SS,TT,QQ,ZZ,m.eigval(1,:,ialt)] = schur_();
   if npath(ialt) == 1
      if ~sspace_()
         npath(ialt) = -1;
      end
   end
end

if forward > 0
   m = expand(m,forward);
end

m.optimal(alt) = false;

% End of function body.

%********************************************************************
%! Nested function schur_().

function [SS,TT,QQ,ZZ,eigval] = schur_()

   % ordered QZ decomposition
   AA = full(system.A{2});
   BB = full(system.B{2});
   [SS,TT,QQ,ZZ] = qz(AA,BB,'real');
   eigval = -vech(ordeig(SS,TT)); % inverse eigvals
   sevn2patch_();
   stable = abs(eigval) >= 1 + tolerance;
   unit = abs(abs(eigval)-1) < tolerance;
   clusters = zeros(size(eigval));
   clusters(unit) = 2;
   clusters(stable) = 1;
   [SS,TT,QQ,ZZ] = ordqz(SS,TT,QQ,ZZ,clusters);
   eigval = -vech(ordeig(SS,TT)); % inverse eigvals
   sevn2patch_();
   warning('off','MATLAB:divideByZero');
      eigval = 1./eigval;
   warning('on','MATLAB:divideByZero');
   nunit = sum(unit);
   nstable = sum(stable);

   % check saddle-path condition
   if nb == nstable + nunit
      npath(ialt) = 1;
   elseif nb > nstable + nunit
      npath(ialt) = 0;
   else
      npath(ialt) = Inf;
   end

%********************************************************************
%! Nested nested function sevn2patch_().

   function sevn2patch_()
      % Largest eig less than 1.
      eigval0 = eigval;
      eigval0(abs(eigval) >= 1-tolerance) = 0;
      eigval0(imag(eigval) ~= 0) = 0;
      if any(eigval0 ~= 0)
         [aux,below] = max(abs(eigval0));
      else
         below = [];
      end      
      % Smallest eig greater than 1.
      eigval0 = eigval;
      eigval0(abs(eigval) <= 1+tolerance) = Inf;
      eigval0(imag(eigval) ~= 0) = Inf;
      if any(~isinf(eigval0))
         [aux,above] = min(abs(eigval0));
      else
         above = [];
      end      
      if ~isempty(below) && ~isempty(above) && abs(eigval(below) + eigval(above) - 2) <= tolerance && abs(eigval(below) - 1) <= 1e-6
         eigval(below) = sign(eigval(below));
         eigval(above) = sign(eigval(above));
         TT(below,below) = sign(TT(below,below))*abs(SS(below,below));
         TT(above,above) = sign(TT(above,above))*abs(SS(above,above));
         warning_(22);
      end
    end
% End of nested nested function sevn2patch_().

end 
% End of nested function schur_().

%********************************************************************
%! Nested function sspace_().

function flag = sspace_()

  flag = true;
  C = QQ*system.K{2};
  D = QQ*full(system.E{2}); % eye([nx,nr]);
  S11 = SS(1:nb,1:nb);
  S12 = SS(1:nb,nb+1:end);
  S22 = SS(nb+1:end,nb+1:end);
  T11 = TT(1:nb,1:nb);
  T12 = TT(1:nb,nb+1:end);
  T22 = TT(nb+1:end,nb+1:end);
  Z11 = ZZ(fkeep,1:nb);
  Z12 = ZZ(fkeep,nb+1:end);
  Z21 = ZZ(nf+1:end,1:nb);
  Z22 = ZZ(nf+1:end,nb+1:end);
  C1 = C(1:nb,1);
  C2 = C(nb+1:end,1);
  D1 = D(1:nb,:);
  D2 = D(nb+1:end,:);

  % quasi-triangular state-space form

  Za = Z21;

  % steady state for non-linear models
  if ~m.linear
    ysstate = trendarray_(m,m.solutionid{1},0,false,ialt);
    xfsstate = trendarray_(m,m.solutionid{2}(1:nfkeep),[-1,0],false,ialt);
    xbsstate = trendarray_(m,m.solutionid{2}(nfkeep+1:end),[-1,0],false,ialt);
    asstate = Za\xbsstate;
    if any(isnan(asstate(:)))
      flag = false;
      return
    end
  end

  % unstable block

  G = -Z21\Z22;
  if any(isnan(G(:)))
    flag = false;
    return
  end
  Ru = -T22\D2;
  if any(isnan(Ru(:)))
    flag = false;
    return
  end
  if m.linear
    Ku = -(S22+T22)\C2;
  else
    Ku = zeros([nfkeep,1]);
  end
  if any(isnan(Ku(:)))
    flag = false;
    return
  end

  % Transform stable block == transform backward-looking variables:
  % a(t) = s(t) + G u(t+1).

  Ta = -S11\T11;
  if any(isnan(Ta(:)))
    flag = false;
    return
  end
  Xa0 = S11\(T11*G + T12);
  if any(isnan(Xa0(:)))
    flag = false;
    return
  end
  Ra = -Xa0*Ru - S11\D1;
  if any(isnan(Ra(:)))
    flag = false;
    return
  end
  Xa1 = G + S11\S12;
  if any(isnan(Xa1(:)))
    flag = false;
    return
  end
  if m.linear
    Ka = -(Xa0 + Xa1)*Ku - S11\C1;
  else
    Ka = asstate(:,2) - Ta*asstate(:,1);
  end
  if any(isnan(Ka(:)))
    flag = false;
    return
  end

  % Forward-looking variables.

  % Duplicit rows (metadelete) already deleted from Z11 and Z12.
  Tf = Z11;
  Xf = Z11*G + Z12;
  Rf = Xf*Ru;
  if m.linear
    Kf = Xf*Ku;
  else
    Kf = xfsstate(:,2) - Tf*asstate(:,1);
  end
  if any(isnan(Kf(:)))
    flag = false;
    return
  end

  % State-space form:
  % [xf(t);a(t)] = T a(t-1) + K + R(L) e(t),
  % Za a(t) = xb(t).
  T = [Tf;Ta];
  K = [Kf;Ka];
  R = [Rf;Ra];

  Za = numerical.removeSmall(Za);
  
  % y(t) = Z a(t) + D + H e(t)
  if ny > 0
    Z = -full(system.A{1}\system.B{1}) * Za;
    if any(isnan(Z(:)))
       flag = false;
       return,
    end
    H = -full(system.A{1})\full(system.E{1}); % eye(ny);
    if any(isnan(H(:)))
       flag = false;
       return
    end
    if m.linear
      D = full(-system.A{1}\system.K{1});
    else
      D = ysstate - Z*asstate(:,2);
    end
    if any(isnan(D(:)))
      flag = false;
      return
    end
    Z = numerical.removeSmall(Z);
    H = numerical.removeSmall(H);
    D = numerical.removeSmall(D);
  else
    Z = zeros([0,nb]);
    H = zeros([0,ne]);
    D = zeros([0,1]);
  end

  % Necessary initial conditions in xb vector.
  m.icondix(1,:,ialt) = any(abs(T/Za) > tolerance,1);

  % forward expansion
  % a(t) <- -Xa J^(k-1) Ru e(t+k)
  % xf(t) <- Xf J^k Ru e(t+k)
  J = -T22\S22;
  Xa = Xa1 + Xa0*J;
  Jk = eye(size(J)); % highest computed power of J: e(t+k) requires J^k

  m.expand{1}(:,:,ialt) = Xa;
  m.expand{2}(:,:,ialt) = Xf;
  m.expand{3}(:,:,ialt) = Ru;
  m.expand{4}(:,:,ialt) = J;
  m.expand{5}(:,:,ialt) = Jk;

  m.solution{1}(:,:,ialt) = T;
  m.solution{2}(:,:,ialt) = R;
  m.solution{3}(:,:,ialt) = K;
  m.solution{4}(:,:,ialt) = Z;
  m.solution{5}(:,:,ialt) = H;
  m.solution{6}(:,:,ialt) = D;
  m.solution{7}(:,:,ialt) = Za;
  
end 
% End of nested function sspace_().

%********************************************************************
%! Nested function allocsolution_().

function allocsolution_()

  if isempty(m.eigval)
    m.eigval = nan([1,nx,nalt],m.precision);
  else
    m.eigval(:,:,alt) = NaN;
  end

  if isempty(m.icondix)
     m.icondix = false([1,nb,nalt]);
  else
     m.icondix(1,:,alt) = false;
  end

  if isempty(m.expand) || isempty(m.expand{1})
    m.expand{1} = nan([nb,nf,nalt],m.precision);
    m.expand{2} = nan([nfkeep,nf,nalt],m.precision);
    m.expand{3} = nan([nf,ne,nalt],m.precision);
    m.expand{4} = nan([nf,nf,nalt],m.precision);
    m.expand{5} = nan([nf,nf,nalt],m.precision);
  else
    m.expand{1}(:,:,alt) = NaN;
    m.expand{2}(:,:,alt) = NaN;
    m.expand{3}(:,:,alt) = NaN;
    m.expand{4}(:,:,alt) = NaN;
    m.expand{5}(:,:,alt) = NaN;
  end

  if isempty(m.solution) || isempty(m.solution{1})
    m.solution{1} = nan([nfkeep+nb,nb,nalt],m.precision); % T
    m.solution{2} = nan([nfkeep+nb,ne,nalt],m.precision); % R
    m.solution{3} = nan([nfkeep+nb,1,nalt],m.precision); % K
    m.solution{4} = nan([ny,nb,nalt],m.precision); % Z
    m.solution{5} = nan([ny,ne,nalt],m.precision); % H
    m.solution{6} = nan([ny,1,nalt],m.precision); % D
    m.solution{7} = nan([nb,nb,nalt],m.precision); % U
  else
    m.solution{1}(:,:,alt) = nan([nfkeep+nb,nb,length(alt)],m.precision);
    if size(m.solution{2},2) > ne
      m.solution{2} = nan([nfkeep+nb,ne,nalt],m.precision);
    else
      m.solution{2}(:,:,alt) = nan([nfkeep+nb,ne,length(alt)],m.precision);
    end
    m.solution{3}(:,:,alt) = nan([nfkeep+nb,1,length(alt)],m.precision);
    m.solution{4}(:,:,alt) = nan([ny,nb,length(alt)],m.precision);
    m.solution{5}(:,:,alt) = nan([ny,ne,length(alt)],m.precision);
    m.solution{6}(:,:,alt) = nan([ny,1,length(alt)],m.precision);
    m.solution{7}(:,:,alt) = nan([nb,nb,length(alt)],m.precision);
  end

end
% End of nested function allocsolution_().

end
% End of primary function.