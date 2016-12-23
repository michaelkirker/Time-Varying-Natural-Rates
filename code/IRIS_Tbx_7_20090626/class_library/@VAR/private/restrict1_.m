function w = restrict1_(w,ny,nk,ng,options)
% Convert parameter restrictions into matrix form.

% The IRIS Toolbox 2008/09/09.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body 

if isnumeric(options.constraints)
   w.Rr = options.constraints;
   return
end

restrict = lower(strtrim(options.constraints));
nlag = options.order;
if ng > 0
   nlag = nlag - 1;
end

if ~isempty(restrict)
   restrict = strrep(lower(restrict),' ','');
   pattern = '=([^\];]*)';
   replace = '-\($1\)';
   restrict = regexprep(restrict,pattern,replace);
   if restrict(1) ~= '['
      restrict = ['[',restrict];
   end
   if restrict(end) ~= ']'
      restrict = [restrict,']'];
   end
end

if ~isempty(restrict)
   [R,r] = read_(restrict,ny,nk,ng,nlag);
   w.Rr = [sparse(R),sparse(r)];
else
   w.Rr = [];
end

end
% end of primary function

% ===========================================================================================================
%! subfunction read_()

function [R,r] = read_(rstring,ny,nk,ng,nlag)

  % Q*beta = q
  aux = reshape(transpose(1:ny*(nk+ny*nlag+ng)),[ny,nk+ny*nlag+ng]);
  cindex = aux(:,1:nk);
  aux(:,1:nk) = [];
  aindex = reshape(aux(:,1:ny*nlag),[ny,ny,nlag]);
  aux(:,1:ny*nlag) = [];
  gindex = aux;
  c = zeros(size(cindex)); % constant
  a = zeros(size(aindex)); % transition matrix
  g = zeros(size(gindex)); % cointegrating vector
  try
    q = vec(eval(rstring));
  catch
    error_(1,{geterrormsg()});
  end
  nrestrict = size(q,1);
  Q = zeros([nrestrict,ny*nk+nlag*ny*ny]);
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

  % convert Q*beta = q to beta = R*gamma + r
  R = null(Q);
  r = -pinv(Q)*q;

end
% end of subfunction read_()