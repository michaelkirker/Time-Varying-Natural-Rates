function h = qpcompare1(range,x,xlegend,dlegend,varargin)

h = plot(range,[x{1}{:,1},x{2}{:,1}],varargin{:});
% legend([xlegend{1},dlegend{1}],[xlegend{2},dlegend{2}],'Location','Best');
grid('on');

end