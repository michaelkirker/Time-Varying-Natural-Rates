function put(this,varargin)
% <a href="matlab: edit container/put">PUT</a>  Store items in IRIS container.
%
% Syntax:
%   put(container,name,item,name,item,...)
% Required input arguments:
%   name [ char ] Names under which the items will be stored.
%   item [ any ] Items to store.

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.%

if ~iscellstr(varargin(1:2:end))
   error('Incorrect type of input argument(s).');
end

n = length(varargin);
if n/2 ~= round(n/2)
   error('Incorrect number of input argument(s).');
end

%********************************************************************
%! Function body.

locked = {};
for i = 1 : 2 : n
   if ~repository_('put',varargin{i},varargin{i+1});
      locked{end+1} = varargin{i};
   end
end

if ~isempty(locked)
   multierror('The entry "%s" is locked. Cannot rewrite the entry.',locked,'iris:general');
end

end
% End of primary function.