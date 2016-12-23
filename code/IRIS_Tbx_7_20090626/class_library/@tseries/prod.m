function x = prod(x,dim)
if nargin < 2
  dim = 1;
end
x = unop_(@prod,x,dim,dim);
end