function [dbase,list0,list] = dbhatch(dbase0,namemask,exprmask,varargin)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if ~isstruct(dbase0) || ~ischar(namemask) || ~ischar(exprmask) || ~iscellstr(varargin(1:2:nargin-3))
  error('Incorrect type of input argument(s).');
end

default = {
  'namefilter',Inf,...
  'classfilter',Inf,...
  'append',true,...
};
options = passopt(default,varargin{:});

% -----function DBHATCH body----- %

[list0,list,expr] = dbquery(dbase0,namemask,exprmask,options);

if options.append == true
  dbase = dbase0;
else
  dbase = struct();
end

invalid = cell([1,0]);
for i = 1 : length(list0)
  try
    value = evalin('caller',expr{i});
  catch
    invalid{end+1} = expr{i};
    continue;
  end
  dbase.(list{i}) = value;
end

if ~isempty(invalid)
  error_(1,invalid);
end

end