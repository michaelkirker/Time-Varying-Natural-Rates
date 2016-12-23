function x = all(x,dim)
if nargin < 2, dim = 1; end  
x = unop_(@all,x,dim,dim);
end