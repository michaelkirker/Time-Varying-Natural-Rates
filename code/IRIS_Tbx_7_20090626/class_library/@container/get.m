function varargout = get(this,varargin)
% <a href="matlab: edit container/get">GET</a>  Retrieve items from IRIS container.
%
% Syntax:
%   [item,item,...] = get(container,name,name,...)
% Output arguments:
%   item [ any ] Items retrieved from global repository (container).
% Required input arguments:
%   name [ char ] Names of items to be retrieved.

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

if ~iscellstr(varargin)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

invalid = {};
for i = 1 : length(varargin)
   [flag,varargout{i}] = repository_('get',varargin{i});
   if ~flag
      invalid{end+1} = varargin{i};
   end
end

if ~isempty(invalid)
   error('Cannot find an entry named "%s" in the container.\n',invalid{:});
end

end
% End of primary function.