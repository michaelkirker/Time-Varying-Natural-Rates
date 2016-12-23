function x = min(x,dim)
if nargin < 2, dim = 1; end
x = unop_(@min,x,dim,[],dim);
end