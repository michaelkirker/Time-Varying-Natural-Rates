function [h,xplot,yplot] = plotdist(x,y,varargin)

x = transpose(x);
y = transpose(y);
if size(y,2) > length(x)-1
  y = y(:,1:length(x)-1);
end

xplot = [x(1);vec(x([1,1],2:end-1));x(end)];
yplot = [];
for i = 1 : size(y,1)
  yplot = [yplot,vec(y([i,i],:))];
end
h = plot(xplot,yplot,varargin{:});

end