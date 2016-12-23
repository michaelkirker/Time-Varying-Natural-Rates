function [x,flag,invalid] = dbfun(fn,d,varargin)
% <a href="matlab: edit data/dbfun">DBFUN</a>  Apply a function to each field of a database or databases.
%
% Syntax:
%   [d,flag,invalid] = dbfun(fn,d,...)
%   [d,flag,invalid] = dbfun(fn,d1,d2,...)
% Output arguments:
%   d [ struct ] Output <a href="databases.html">database</a>.
%   flag [ true | false ] True if no error occurs when evaluating the function.
%   invalid [ cellstr ] List of fields on which the function fails.
% Required input arguments:
%   fn [ function_handle | char ] Function to be applied to each field.
%   d,d1,d2 [ struct ] Input <a href="databases.html">database(s)</a>.
% <a href="options.html">Optional input arguments:</a>
%   'classfilter' [ cell | cellstr | <a href="default.html">Inf</a> ] Apply only to fields of selected classes.
%   'merge' [ <a href="default.html">true</a> | false ] Incorporate uprocessed fields with output database.

% The IRIS Toolbox 2008/10/10.
% Copyright (c) 2007-2008 Jaromir Benes.

if ~(ischar(fn) || isa(fn,'function_handle')) || ~isstruct(d)
  error('Incorrect type of input argument(s).');
end

% find last database in varargin
index = find(cellfun(@isstruct,varargin),1,'last') ;
if isempty(index)
  index = 0;
end

default = {...
  'classfilter',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x) || iscellstr(x),...
  'merge',true,@islogical,...
};
options = passvalopt(default,varargin{index+1:end});

if ischar(options.classfilter)
  options.classfilter = charlist2cellstr(options.classfilter);
end

% =======================================================================================
%! Function body.

list = fieldnames(d);

if options.merge
   x = d;
else
   x = struct();
end

flag = true;
invalid = {};
for i = 1 : length(list)
   if ~isnumeric(options.classfilter) && ~any(strcmp(class(d.(list{i})),options.classfilter))
      continue
   end
   try
      arglist = {d.(list{i})};
      for j = 1 : index
         arglist(end+1) = {varargin{j}.(list{i})};
      end
      x.(list{i}) = fn(arglist{:});
   catch
      x.(list{i}) = NaN;
      invalid{end+1} = list{i};
   end
end

%{
if ~isempty(invalid)
   flag = false;
   warning('Unable to apply the function to this database entry: "%s".\n',invalid{:});
end
%}

end
% End of primary function.