function x = mldivide(x,y)
if istseries(x) && istseries(y)
  fn = @ldivide;
elseif isnumeric(y) && length(y) == 1
  fn = @ldivide;
else
  fn = @mldivide;
end
x = binop_(fn,x,y);
end