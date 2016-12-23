function x = mean(x,dim)
if nargin  < 2, dim = 1; end
x = unop_(@mean,x,dim,dim);
end