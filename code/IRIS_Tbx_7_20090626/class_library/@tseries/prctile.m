function x = prctile(x,p,dim)
if nargin < 3
  dim = 1;
end
x = unop_(@prctile,x,dim,p,dim);
end