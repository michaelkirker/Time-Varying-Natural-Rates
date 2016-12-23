function x = normcdf(x,varargin)
x = unop_(@normcdf,x,0,varargin{:});
end