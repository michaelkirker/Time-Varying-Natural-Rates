function h = qlegend(position,varargin)

h = legend(varargin{:});
set(h,'position',getsubposition(position));

end