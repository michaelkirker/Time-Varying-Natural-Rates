function x = mrdivide(x,y)
if istseries(x) && istseries(y)
  fn = @rdivide;
elseif isnumeric(x) && length(x) == 1
  fn = @rdivide;
else
  fn = @mrdivide;
end
x = binop_(fn,x,y);
end