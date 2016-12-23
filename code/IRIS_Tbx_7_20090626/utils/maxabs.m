function d = maxabs(x,y)

if nargin > 1
   x = x - y;
end

d = max(vec(abs(x)));

end