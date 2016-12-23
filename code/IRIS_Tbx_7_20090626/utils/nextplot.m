function h = nextplot(x,varargin)

if nargin > 0
   if length(x) == 2
      x = [x,0];
   end
   figure('userData',x,varargin{:});
   return
end   

fg = gcf();
x = get(fg,'userData');

if ~isnumeric(x) || length(x) < 2 || length(x) > 3
   error('Cannot use NEXTPLOT in this figure.');
end

if length(x) == 2
   x = [x,0];
end

if x(3) >= x(1)*x(2)
   x(3) = 0;
   fg = figure();
end

x(3) = x(3) + 1;
h = subplot(x(1),x(2),x(3));
set(fg,'userData',x);

end