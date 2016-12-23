function x = any(x,dim)
if nargin < 2, dim = 1; end
x = unop_(@any,x,dim,dim);
end