function [array,range,comment,source] = dbdouble(d,list,range)
%
% DBDOUBLE  Time series to numeric array conversion of database entries
%
% Syntax:
%   [x,range,cmt] = dbdouble(d,list,range)
% Required input arguments:
%   x numeric; range numeric; cmt cellstr; d struct; list cellstr
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%%

if nargin < 3
   range = Inf;
end

if ~isstruct(d) || ~iscellstr(list) || (~isnumeric(range) && ~ischar(range))
  error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%% function body

if nargin < 3
   range = 'max';
end

if isnumeric(list) && all(isinf(list)), list = dbobjects(d,'tseries');
  elseif isa(list,'char'), list = {list}; end

x = tseries(nan,[]);
invalid = cell([1,0]);
for i = 1 : length(list)
  try, x = [x,d.(list{i})];
  catch, invalid{end+1} = list{i}; end
end

if ~isempty(invalid), error_(2,invalid); end

[array,range,cmt] = double(x,range);

end
% end of primary function