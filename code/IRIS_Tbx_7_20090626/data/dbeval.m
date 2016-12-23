function varargout = dbeval(d,varargin)
% <a href="dbase/dbeval">DBEVAL</a>  Evaluate expressions within database.
%
% Syntax:
%   [value,value,...] = dbeval(d,expr,expr,...)
% Output arguments:
%   value [ any ] Value of expression.
% Required input arguments:
%   d [ struct ] Database in which expressions will be evaluated.
%   expr [ char ] Expressions to evaluate.

% The IRIS Toolbox 2008/12/03.
% Copyright (c) 2007-2008 Jaromir Benes.

if ~isstruct(d) || (~iscellstr(varargin) && ~iscellstr(varargin{1}))
   error('Incorrect type of input argument(s).');
end

if iscellstr(varargin)
   expr = varargin;
   flag = true;
elseif iscellstr(varargin{1})
   expr = varargin{1};
   flag = false;
end

%********************************************************************
%! Function body.

list = vech(fieldnames(d));
list(strmatch('IRIS_',list)) = [];
for i = 1 : length(list)
  expr = regexprep(expr,['(?<![\.@])(\<',list{i},'\>)'],'?.$1');
end

expr = strrep(expr,'?.','d.');
expr = strrep(expr,'@','');
expr = strrep(expr,';','');

% Convert x=y and x+=y into x-(y)
% so that we can evaluate LHS minus RHS.
expr = strrep(expr,'+=','=');
index = strfind(expr,'=');
for i = 1 : length(index)
   if length(index{i}) == 1
      expr{i} = [expr{i}(1:index{i}-1),'-(',expr{i}(index{i}+1:end),')'];
   end
end

if flag
   for i = 1 : length(expr)
      varargout{i} = eval(expr{i},'NaN');
   end
else
   varargout{1} = [];
   for i = 1 : length(expr)
      x = eval(expr{i},'NaN');
      varargout{1} = [varargout{1},x];
   end
end

end
% End of primary function.