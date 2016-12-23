function d = dbmerge(varargin)
% <a href="dbase/dbmerge">DBMERGE</a>  Merge two or more databases.
%
% Syntax:
%   d = dbmerge(d,d1,...)
%   d = dbmerge(d,names,values)
%   d = dbmerge(d,name,value,name,value,...)
% Output arguments:
%   d [ struct ] Output database.
% Required input arguments:
%   d [ struct ] First input database.
%   d1 [ struct ] Second and further input databases.
%   names [ cellstr ] List of new field names.
%   values [ char ] Cell array of new field values.
%   name [ any ] New field name.
%   value [ cell ] New field value.

% The IRIS Toolbox 2009/04/07.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if nargin == 0
   % No input arguments.
   d = struct();
   return
end

if nargin == 1
   % One input argument.
   d = varargin{1};
   return
end

names = vech(fieldnames(varargin{1}));
values = vech(struct2cell(varargin{1}));

if nargin == 3 && iscellstr(varargin{2})
   % dbmerge(d,names,values)
   names = [names,vech(varargin{2})];
   values = [values,vech(varargin{3})];
elseif nargin > 2 && iscellstr(varargin(2:2:end-1))
   % dbmerge(d,name,value,name,value,...)
   names = [names,varargin(2:2:end-1)];
   values = [values,varargin(3:2:end)];
else
   % dbmerge(d1,d2,...)
   for i = 2 : nargin
      names = [names,vech(fieldnames(varargin{i}))];
      values = [values,vech(struct2cell(varargin{i}))];
   end
end

% Catch indices of last occurences.
[names,index] = unique(names,'last');

d = cell2struct(values(index),names,2);

end
% End of primary function.
