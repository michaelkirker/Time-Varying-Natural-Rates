function varargout = irisget(varargin)
[varargout{1:max([nargout,1])}] = irisconfig('get',varargin{:});
end