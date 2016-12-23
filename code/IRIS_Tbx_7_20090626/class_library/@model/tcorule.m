function [m,Q,W,Qlist,Wlist,count,Y,L,discrep] = tcorule(m,uname,ueqtn,R,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.tcorule">idoc model.tcorule</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/05/13.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'beta',1,...
   'display',5000,...
   'ginverse',false,...
   'initexp',@eye,...
   'maxiter',50000,...
   'tolexp',1e-12,...
   'tolrule',1e-12,...
   'tolvalue',1e-12,...
};
options = passopt(default,varargin{:});

if ischar(uname)
   uname = {uname};
end

if ischar(ueqtn)
   ueqtn = {ueqtn};
end

%********************************************************************
%! Function body.

% N.B.: Constants and measurement errors ignored

realsmall = getrealsmall();
ny = length(m.systemid{1});
nx = length(m.systemid{2});
nf = sum(imag(m.systemid{2}) >= 0);
nb = nx - nf;
ne = length(m.systemid{3});

% works only with single parameterisation 
if size(m.assign,3) > 1
  error_(47,'TCORULE');
end

% size of weighting matrix/vector == number of measurement variables
if length(R) ~= ny
  error_(58);
end

% at least one non-zero element in weighting matrix/vector
if all(all(R == 0))
  error_(59);
end

if any(size(R)) == 1
  % input is weighting vector
  Rdiag = vech(R);
  R = diag(R);
  isrdiag = true;
else
  % input is weighting matrix
  Rdiag = vech(diag(R));
  isrdiag = all(all((diag(Rdiag) - R) == 0));
  % R must be symmetric
  if maxabs(triu(R) - transpose(tril(R))) > realsmall
    error_(63);
  end
end

eqselect = eqselect_(m,1);
eqselect(m.eqtntype == 3) = false;
[m,deriv] = deriv_(m,eqselect,1);
[m,sys] = system_(m,deriv,eqselect,1);

unameix = findnames(m.name,uname);
ueqtnix = findnames(m.eqtnlabel(m.nametype == 2),ueqtn);
% all names found?
index = isnan(unameix);
if any(index)
  error_(60,uname(index));
end
% all equation labels found?
index = isnan(ueqtnix);
if any(index)
  error_(61,ueqtn(index));
end

nu = length(unameix); % number of instruments
if length(ueqtnix) ~= nu
  error_(62);
end

% drop current policy rule from equations
sys.A{2}(ueqtnix,:) = 0;
sys.B{2}(ueqtnix,:) = 0;
sys.E{2}(ueqtnix,:) = 0;
sys.K{2}(ueqtnix,:) = 0;

% add policy instrument and its identity to equations
for i = 1 : length(unameix)
  uix = find(real(m.systemid{2}) == unameix(i) & imag(m.systemid{2}) == -1);
  if isempty(uix)
    uix = find(real(m.systemid{2}) == unameix(i) & imag(m.systemid{2}) == 0);
    % time t policy instrument is unpredermined variable
    sys.B{2}(ueqtnix(i),uix) = -1;
  else
    % time t policy instrument is predermined variable
    sys.A{2}(ueqtnix(i),uix) = -1;
  end
end

% A*[xf+;xb] + B*[xf;xb-] + C*e + D*u = 0
A = sys.A{2};
B = sys.B{2};
C = sys.E{2};
D = sparse(zeros([nx,nu]));
D(ueqtnix,1:nu) = eye(nu);

% G*y + H*xb + J*e = 0
G = sys.A{1};
H = sys.B{1};
% J = sys.E{1};

%{
if m.linear
  % add constant
  A(end+1,end+1) = 1;
  B(end+1,end+1) = -1;
  B(1:end-1,end) = sys.K{2}(:,1);
  C(end+1,:) = 0;
  D(end+1,:) = 0;
  H(:,end+1) = sys.K{1}(:,1);
  nx = nx + 1;
  nb = nb + 1;
end
%}

A1 = A(:,1:nf);
A2 = A(:,nf+1:end);
B1 = B(:,1:nf);
B2 = B(:,nf+1:end);

Gi = inv(full(G));
B2CD = full([B2,C,D]);

iterate = true;
% E(xf) = Z*xb;
Z = options.initexp([nf,nb]);
% value = y'*R*y + beta*xb'*P*xb
P = zeros(nb);
% policy function u = Q*[xb-;e]
Q = inf([nu,nb+ne]);

count = 0;

if isrdiag
  rnonzero = Rdiag ~= 0;
else
  rnonzero = any(R ~= 0,1);
end

heading = true;
while iterate && count < options.maxiter

  % Step I
  % find [xf;xb] = E*[xb-;e;u]
  if options.ginverse
    E = ginverse(full(-[B1,A1*Z+A2])) * B2CD;
  else
    lastwarn('');
    status = warning();
    warning('off');
    E = full(-[B1,A1*Z+A2]) \ B2CD;
    warning(status);
    if ~isempty(strfind(lastwarn(),'singular'))
      E = ginverse(full(-[B1,A1*Z+A2])) * B2CD;
    end
  end
  E1 = E(1:nf,:);
  E11 = E1(:,1:nb);
  E12 = E1(:,nb+(1:ne));
  E13 = E1(:,nb+ne+(1:nu));
  E2 = E(nf+1:end,:);
  E21 = E2(:,1:nb);
  E22 = E2(:,nb+(1:ne));
  E23 = E2(:,nb+ne+(1:nu));

  % Step II
  % find y = K*[xb-;e;u]
  K = -Gi * full([H*E21,H*E22,H*E23]); % J (measurement errors) ignored

  % Step III
  % convert y'*R*y + beta*xb'*P*xb into [xb-;e;u]'*Rtilda*[xb-;e;u]
  % Rtilda = [L,M;M',N]
  % Rtilda = K'*R*K + beta*E2'*P*E2
  Rtilda = options.beta*transpose(E2)*P*E2;
  if isrdiag
    Kt_R = zeros(nb+ne+nu);
    Kt_R(:,rnonzero) = transpose(K(rnonzero,:)) .* Rdiag(ones([1,nb+ne+nu]),rnonzero);
    Rtilda = Rtilda + Kt_R(:,rnonzero)*K(rnonzero,:);
  else
    Rtilda = Rtilda + transpose(K(rnonzero,:))*R(rnonzero,rnonzero)*K(:,rnonzero);
  end
  L = Rtilda(1:nb+ne,1:nb+ne);
  M = Rtilda(1:nb+ne,nb+ne+(1:nu));
  N = Rtilda(nb+ne+(1:nu),nb+ne+(1:nu));

  % Step IV
  % min [xb-;e;u]'*[L,M;M',N]*[xb-;e;u] s.t. transition equations
  % and solve for u = Q*[xb-;e]
  Q0 = Q;
  Q = -N \ transpose(M);

  % Step V
  % find Y such that [xb-;e]'*Y*[xb-;e] == y'*R*y + beta*xb'*P*xb with u = Q*[xb-;e]
  % and update P
  MQ = M*Q;
  Y = L + MQ + transpose(MQ) + transpose(Q)*N*Q;
  P0 = P;
  P = Y(1:nb,1:nb);

  % Step VI
  % find xf = S*[xb-;e]
  % and update Z
  S1 = [E11,E12] + E13*Q;
  Z0 = Z;
  Z = S1(:,1:nb);

  iterate = any(abs(Q(:)-Q0(:)) > options.tolrule) || any(abs(P(:)-P0(:)) > options.tolvalue) || any(abs(Z(:)-Z0(:)) > options.tolexp);
  count = count + 1;
  if mod(count,options.display) == 0
    if heading
       disp(sprintf('%10s%15s%15s%15s','Iter','Rule','Value fcn','Expectations'));
       heading = false;
    end
    discrep = [max(abs(Q(:)-Q0(:))),max(abs(P(:)-P0(:))),max(abs(Z(:)-Z0(:)))]; 
    disp(sprintf('%10g%15g%15g%15g',count,discrep));
  end

end

discrep = [max(abs(Q(:)-Q0(:))),max(abs(P(:)-P0(:))),max(abs(Z(:)-Z0(:)))]; 

% convergence not reached
if iterate
   warning_(42,options.maxiter);
elseif ~heading
   disp(' ');
end

% Step VII
% convert Q into "targeting rule" W*xb = 0

% find [xf;xb] = E*[xb-;e;u]
E = full(-[B1,A1*Z+A2]) \ B2CD;
E23 = E(nf+1:end,nb+ne+(1:nu));

% find y = V*xb
V = -Gi*H;

% convert y'*R*y + beta*xb'*P*xb into xb'*U*xb
% U := V'*R*V + beta*P
U = transpose(V)*R*V + options.beta*P;

% find targeting rule
W = transpose(E23)*U;

% try to plug targeting rule into original system
sys.A{2}(ueqtnix,nf+1:end) = W;
sys.B{2}(ueqtnix,:) = 0;
% try to plug instrument rule into original system
%sys.B{2}(ueqtnix,nf+1:end) = Q(:,1:nb);
%sys.E{2}(ueqtnix,:) = Q(:,nb+(1:ne));

% calculate constant terms to preserve existing steady state
if m.linear
  xbar = trendarray_(m,m.systemid{2}(nf+1:end),0,false);
  sys.K{2}(ueqtnix,1) = -W*xbar;
end

%status = warning();
%warning('off','iris:model');
[m,npath] = solve(m,'system',sys);
% warning(status);

%{
if npath ~= 1

  % use the iterated policy function if the above fails to produce unique stable solution
  % warning_(43);

  E = full(-[B1,A1*Z+A2]) \ B2CD;
  E1 = E(:,1:nb);
  E2 = E(:,nb+(1:ne));
  E3 = E(:,nb+ne+(1:nu));
  % plug in optimal rule and find [xf;xb] = S1*[xb-;e]
  S = [E1,E2] + E3*Q;

  % transition equations
  TT = S(:,1:nb);
  RR = S(:,nb+(1:ne));

  % delete duplicate variables
  TT(find(m.metadelete),:) = [];
  RR(find(m.metadelete),:) = [];
  fkeep = ~m.metadelete;
  nfkeep = sum(fkeep);
  m.solutionid = {...
    m.systemid{1},...
    [m.systemid{2}(find(fkeep)),1i+m.systemid{2}(nf+1:end)],...
    m.systemid{3},...
  };

  % set constants to preserve current steady state
  xbar = trendarray_(m,m.solutionid{2},[0,-1],false);
  KK = xbar(:,1) - TT*xbar(nfkeep+1:end,2);

  % measurement equations
  ZZ = -Gi*full(sys.B{1});
  HH = -Gi*full(sys.E{1});
  DD = -Gi*full(sys.K{1});

  % find triangular representation
  [UU,TT(nfkeep+1:end,:)] = schur(TT(nfkeep+1:end,:));
  eigval = ordeig(TT(nfkeep+1:end,:));
  unitroots = abs(abs(eigval) - 1) < realsmall;
  [UU,TT(nfkeep+1:end,:)] = ordschur(UU,TT(nfkeep+1:end,:),unitroots);
  TT(1:nfkeep,:) = TT(1:nfkeep,:)*UU;
  RR(nfkeep+1:end,:) = transpose(UU)*RR(nfkeep+1:end,:);
  KK(nfkeep+1:end,1) = transpose(UU)*KK(nfkeep+1:end,1);
  ZZ = ZZ*UU;

  % update eigenvalues
  m.eigval = inf([1,nx]);
  m.eigval(1,1:nb) = vech(ordeig(TT(end-nb+1:end,:)));


  % update solution
  m.solution{1} = TT;
  m.solution{2} = RR;
  m.solution{3} = KK;
  m.solution{4} = ZZ;
  m.solution{5} = HH;
  m.solution{6} = DD;
  m.solution{7} = UU;

  % forward expansion not available
  for i = 1 : length(m.expand)
    m.expand{i}(:,:) = NaN;
  end
 warning('***');
end % if npath ~= 1
%}

m.optimal = true;

if nargout > 4
   id = m.systemid{2}(nf+1:end);
   Qlist = [...
      printid(m.name(real(id)),imag(id),m.log(real(id))),...
      printid(m.name(m.nametype == 3),zeros([1,ne]),false([1,ne])),...
      ];
   Wlist = printid(m.name(real(id)),imag(id)+1,m.log(real(id)));
end

end
% End of primary function.