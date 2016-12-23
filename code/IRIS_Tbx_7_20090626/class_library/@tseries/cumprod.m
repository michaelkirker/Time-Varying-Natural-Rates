function x = cumprod(x,varargin)

x = unop_(@cumprod,x,0,1);

if length(varargin) > 0
  if length(varargin) > 1
    start = varargin{2};
  else
    start = get(x,'start');
  end
  y = varargin{1};
  y = resize(y,[-inf,start-1]);
  x = [y;x*getdata_(y,start-1)];
end

end