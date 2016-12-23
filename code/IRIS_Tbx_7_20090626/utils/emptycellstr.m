function varargout = emptycellstr(varargin)
   varargout{1} = cell(varargin{1});
   varargout{1}(:) = {''};
end