function [options,invalid,useroptions] = passvalopt(default,varargin)
% Pass and validate optional arguments.

% The IRIS Toolbox 2008/10/25.
% Copyright (c) 2007-2008 Jaromir Benes.

valid = default(3:3:end);
optionname = default(1:3:end);
default(3:3:end) = [];

if isstruct(default)
   options = default;
else
   options = cell2struct(default(2:2:end),default(1:2:end),2);
end

% =======================================================================================
%! Function body.

if nargin == 1,
   invalid = {};
   useroptions = struct();
   return
end

if nargin == 2 && isstruct(varargin{1})
   % Called passvalopt(default,struct).
   useroptions = varargin{1};
elseif nargin == 2 && iscell(varargin{1});
   % Called passvalopt(default,{'name',value}).
   aux = varargin{1};
   aux(1:2:nargin-1) = lower(aux(1:2:nargin-1));
   useroptions = cell2struct(aux(2:2:end),aux(1:2:end),2);
elseif nargin > 2 && iscellstr(varargin(1:2:nargin-1))
   % Called passopt(default,'name',value).
   if rem(nargin,2) ~= 1
      error('This option has no value assigned: "%s".',varargin{end});
   end
   varargin(1:2:nargin-1) = lower(varargin(1:2:nargin-1));
   useroptions = cell2struct(varargin(2:2:end),varargin(1:2:end),2);
else
   error('Incorrect list of user options.');
end

username = fieldnames(useroptions);
invalid = {};
used = {};
for i = 1 : length(username)
   if ~isfield(options,username{i})
      invalid{end+1} = username{i};
   else
      options.(username{i}) = useroptions.(username{i});
      used{end+1} = username{i};
   end
end

if isfield(options,'X')
   useroptions = rmfield(useroptions,used);
else
   if ~isempty(invalid)
      warning('iris:options','\nInvalid or obsolete option "%s". Option not used.',invalid{:});
   end
end

invalid = {};
for i = 1 : length(optionname)
   if ~isempty(valid{i})
      flag = valid{i}(options.(optionname{i}));
      if ~flag
         invalid{end+1} = optionname{i};
      end
   end
end
if ~isempty(invalid)
   multierror('Invalid type of value assigned to optional argument "%s".',invalid);
end

end
% End of primary function.