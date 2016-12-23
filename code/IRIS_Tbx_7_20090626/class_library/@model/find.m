function varargout = find(m,varargin)
% <a href="model/find">FIND</a>  Find equations, variables, and/or parameters by matching their labels/comments.
%
% Syntax:
%   [list,list,...] = find(m,rexp,rexp,...)
% Output arguments:
%   list [ cellstr ] List of equations, variables, or parameters that match regular expression.
% Required input arguments:
%   m [ model ] Model.
%   rexp [ char ] Label/comment, or regular expression to be matched.

% The IRIS Toolbox 2009/02/13.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

for i = 1 : length(varargin)
  index1 = regexp(m.namelabel,sprintf('^%s$',varargin{i}));
  index1 = find(~cellfun(@isempty,index1));
  index2 = regexp(m.eqtnlabel,sprintf('^%s$',varargin{i}));
  index2 = find(~cellfun(@isempty,index2));
  varargout{i} = [m.name(index1),m.eqtn(index2)];
end

end
% End of primary function.