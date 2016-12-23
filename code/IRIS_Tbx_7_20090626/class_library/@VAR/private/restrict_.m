function [R,r,nhyper] = restrict_(restrict,R0,Q0,ny,nk,ng,order)
%
% RVAR/PRIVATE/RESTRICT_  Convert parameter restrictions into matrix form.

% The IRIS Toolbox 2008/09/09.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body 

if isnumeric(restrict) && ~isempty(restrict)
  R = restrict(:,1:end-1);
  r = restrict(:,end);
elseif ischar(restrict)
  if ~isempty(restrict)
    restrict = strrep(lower(restrict),' ','');
    patt = '=([^\];]*)';
    repl = '-\($1\)';
    restrict = regexprep(restrict,patt,repl);
    if restrict(1) ~= '['
       restrict = ['[',restrict];
    end
    if restrict(end) ~= ']'
       restrict = [restrict,']'];
    end
  end

  if ~isempty(restrict)
    [R,r] = read_(Q0,restrict,ny,nk,ng,order);
  elseif ~isempty(R0)
    R = R0;
    r = zeros([size(R0,1),1]);
  else
    R = [];
    r = [];
  end
else
  R = [];
  r = [];
end

if isempty(R)
  nhyper = order*ny+nk+ng;
else
  nhyper = size(R,2);
end

R = sparse(R);
r = sparse(r);

end
% end of primary function

% ===========================================================================================================
%! subfunction read_()

function [R,r] = read_(Q0,rstring,ny,nk,ng,order)

  % Q*beta = q
  aux = reshape(transpose(1:ny*(ny*order+nk+ng)),[ny,ny*order+nk+ng]);
  aindex = reshape(aux(:,1:ny*order),[ny,ny,order]);
  aux(:,1:ny*order) = [];
  cindex = aux(:,1:nk);
  aux(:,1:nk) = [];
  gindex = aux;
  a = zeros(size(aindex)); % transition matrix
  c = zeros(size(cindex)); % constant
  g = zeros(size(gindex)); % cointegrating vector
  try
    q = vec(eval(rstring));
  catch
    error_(1,{geterrormsg()});
  end
  nrestrict = size(q,1);
  Q = zeros([nrestrict,order*ny*ny+ny*nk]);
  for i = 1 : numel(c)
    c(i) = 1;
    Q(:,cindex(i)) = vec(eval(rstring)) - q;
    c(i) = 0;
  end
  for i = 1 : numel(a)
    a(i) = 1;
    Q(:,aindex(i)) = vec(eval(rstring)) - q;
    a(i) = 0;
  end
  for i = 1 : numel(g)
    g(i) = 1;
    Q(:,gindex(i)) = vec(eval(rstring)) - q;
    g(i) = 0;
  end
  if ~isempty(Q0)
    Q = [Q;Q0];
    q = [q;zeros([size(Q0,1),1])];
  end

  % convert Q*beta = q --> beta = R*gamma + r
  R = null(Q);
  r = -pinv(Q)*q;

end
% end of subfunction read_()