function x = max(x,dim)
if nargin < 2, dim = 1; end
x = unop_(@max,x,dim,[],dim);
end