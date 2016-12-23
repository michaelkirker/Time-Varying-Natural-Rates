function x = nanmean(x,dim)
if nargin < 2, dim = 1; end
x = unop_(@nanmean,x,dim,dim);
end