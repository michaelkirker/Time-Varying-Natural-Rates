function y = sizeof(x,n)
y = cell([1,n]);
[y{:}] = size(x);
y = [y{:}];
end