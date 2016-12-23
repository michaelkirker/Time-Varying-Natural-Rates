function x = logncdf(x,varargin)
x = unop_(@logncdf,x,0,varargin{:});
end