function h = qpcompare2(range,x,xlegend,dlegend,varargin)

% plot(range,[x{1},x{2}{:,2}]);
% [li,ba,lhs,rhs] = linebar(range,[x{1},x{2}{:,2}],x{2}{:,2}-x{1}{:,2});
h = plot(range,[x{1},x{2}{:,2}]);
if any(~cellfun(@isempty,xlegend))
  h = legend(xlegend{1},[xlegend{2},dlegend{1}],[xlegend{2},dlegend{2}],'Location','Best');
% grid('on');
  fontsize = get(gca,'FontSize');
%h = legend(lhs,dlegend{1},dlegend{2},'Location','Best');
%set(h,'Orientation','Horizontal','FontSize',fontsize-2);
  set(h,'FontSize',fontsize-2);
end
grid('on');

end