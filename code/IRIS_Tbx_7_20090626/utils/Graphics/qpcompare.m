function h = qpcompare(range,x,xlegend,dlegend,varargin)

h = qpdefault(range,x,xlegend,dlegend,varargin{:});
xlegend2 = cell([1,2*length(xlegend)]);
xlegend2(1:2:end) = xlegend;
xlegend2(2:2:end) = {''};
last = find(~cellfun(@isempty,xlegend2),1,'last');
if ~isempty(last)
   legend(xlegend2{1:last+1},'Location','Best');
end

end