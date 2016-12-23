function x = normpdf(x,varargin)
x = unop_(@normpdf,x,0,varargin{:});
end