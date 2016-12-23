function m = meta_(m,options)
% META_  Create model-specific meta data.

% The IRIS Toolbox 2009/06/12.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if issparse(m.occur)
   m.occur = reshape(full(m.occur),[size(m.occur,1),length(m.name),size(m.occur,2)/length(m.name)]);
end

nname = [sum(m.nametype == 1),sum(m.nametype == 2),sum(m.nametype == 3),sum(m.nametype == 4)];

t = m.tzero;
n = sum(nname(1:3));

% Find max lags and leads for east transition variable.
shift = zeros([2,nname(2)]);
for i = 1 : nname(2)
   slice = m.occur(:,nname(1)+i,:);
   aux = vech(find(any(slice(m.eqtntype == 2,1,:),1))) - t;
   if ~isempty(aux)
      shift(1,i) = min([shift(1,i),aux]);
      shift(2,i) = max([shift(2,i),aux]);
      % Evaluate farthest leads for nonlinear simulations.
      % shift(2,i) = iff(shift(2,i) > 0 && m.linear == false,shift(2,i)+1,shift(2,i));
   end
   % If x(t-k) occurs in measurement equations
   % then add k-1 lag.
   aux = vech(find(any(slice(m.eqtntype == 1,1,:),1))) - t;
   if ~isempty(aux)
      shift(1,i) = min([shift(1,i),min(aux)-1]);
   end
   % If the variables is static, consider it forward-looking
   % to reduce state space.
   if shift(1,i) == shift(2,i)
      shift(2,i) = 1;
   end
end

m.systemid{1} = find(m.nametype == 1);
m.systemid{3} = find(m.nametype == 3);
m.systemid{2} = zeros([1,0]);
Min = min(shift(1,1:end));
Max = max(shift(2,1:end));
for i = Max : -1 : Min
  aux = find(i >= shift(1,1:end) & i < shift(2,1:end));
  m.systemid{2} = [m.systemid{2},complex(nname(1)+aux,i)];
end

nx = length(m.systemid{2});
nu = sum(imag(m.systemid{2}) >= 0);
np = nx - nu;

[m.metaderiv.y,m.metaderiv.uplus,m.metaderiv.u,m.metaderiv.pplus,m.metaderiv.p,m.metaderiv.e] = ...
  deal(zeros([1,0]));
[m.metasystem.y,m.metasystem.uplus,m.metasystem.u,m.metasystem.pplus,m.metasystem.p,m.metasystem.e] = ...
  deal(zeros([1,0]));

m.metaderiv.y = (t-1)*n + find(m.nametype == 1);
m.metasystem.y = 1 : nname(1);

[m.systemident.xplus,m.systemident.x] = deal(zeros([0,nx]));

% Delete double occurences.
m.metadelete = false([1,nu]);
for i = 1 : nu
   if any(m.systemid{2}(i)-1i == m.systemid{2}(nu+1:end))
      m.metadelete(i) = true;
   end
end

for i = 1 : nu
   id = m.systemid{2}(i);
   if imag(id) == shift(1,real(id)-nname(1))
      m.metaderiv.u(end+1) = (imag(id)+t-1)*n + real(id);
      m.metasystem.u(end+1) = i;
   end
   m.metaderiv.uplus(end+1) = (imag(id)+t+1-1)*n + real(id);
   m.metasystem.uplus(end+1) = i;
end

for i = 1 : np
   id = m.systemid{2}(nu+i);
   if imag(id) == shift(1,real(id)-nname(1))
      m.metaderiv.p(end+1) = (imag(id)+t-1)*n + real(id);
      m.metasystem.p(end+1) = i;
   end
   m.metaderiv.pplus(end+1) = (imag(id)+t+1-1)*n + real(id);
   m.metasystem.pplus(end+1) = i;
end

m.metaderiv.e = (t-1)*n + find(m.nametype == 3);
m.metasystem.e = 1 : nname(3);

for i = 1 : nu+np
   id = m.systemid{2}(i);
   if imag(id) ~= shift(1,real(id)-nname(1))
      aux = zeros([1,nu+np]);
      aux(m.systemid{2} == id-1i) = 1;
      m.systemident.xplus(end+1,1:end) = aux;
      aux = zeros([1,nu+np]);
      aux(i) = -1;
      m.systemident.x(end+1,1:end) = aux;
   end
end

m.occur = sparse(m.occur(:,:));

% solution IDs
ny = length(m.systemid{1});
nx = length(m.systemid{2});
nb = sum(imag(m.systemid{2}) < 0);
nf = nx - nb;
ne = length(m.systemid{3});
fkeep = ~m.metadelete;

m.solutionid = {...
   m.systemid{1},...
   [m.systemid{2}(find(fkeep)),1i+m.systemid{2}(nf+1:end)],...
   m.systemid{3},...
};

end
% End of primary function.