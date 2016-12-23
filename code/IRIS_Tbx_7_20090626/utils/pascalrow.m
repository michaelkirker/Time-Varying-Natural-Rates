function [x,x2] = pascalrow(n,sign)

if nargin == 1
   sign = 1;
end

if n == 0
   x = 1;
   x2 = 1;
   return
end

% Pascal triangle.
x = [1,1];
for i = 2 : n
   x = sum([x(1:end-1);x(2:end)],1);
   x = [1,x,1];
end

% Row x row.
if nargout > 1
   x2 = x;
   for i = 2 : n+1
      x2(i,i:end+1) = x(i)*x;
   end
end

end