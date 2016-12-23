function x = logtrend(x,varargin)
x = unop_(@logtrend,x,0,varargin{:});
end