function a = geomean(x,dim)
if nargin < 2, dim = 1; end
a = unop_(@geomean,x,dim,dim);
end