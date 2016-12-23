function histogram(x,varargin)

if nargin < 2, N = 10;
  else N = varargin{1}; end

hist(x,N);
if nargin > 2
  h = ref(get(gca,'children'),1);
  set(h,varargin{2:end});
end

end