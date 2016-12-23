function xtickfrq2per(h,format)

if nargin < 2, format = '%.1f'; end

aux = warning('query','MATLAB:divideByZero');
warning('off','MATLAB:divideByZero');
xtick = 2*pi./get(h,'xtick');
warning(aux.state,'MATLAB:divideByZero');
xticklabel = {};
for i = 1 : length(xtick)
  xticklabel{i} = sprintf(format,xtick(i));
end
set(h,'xticklabel',xticklabel,'xtickmode','manual');

end