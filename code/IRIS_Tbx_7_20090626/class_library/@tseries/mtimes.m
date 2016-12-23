function x = mtimes(x,y)
if istseries(x) && istseries(y), fn = @times;
  else fn =   @mtimes; end
x = binop_(fn,x,y);
end