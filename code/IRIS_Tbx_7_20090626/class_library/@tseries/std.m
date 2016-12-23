function x = std(x,flag,dim)
if nargin < 2
   flag = 0;
end
if nargin < 3
   dim = 1;
end
x = unop_(@std,x,dim,flag,dim);
end