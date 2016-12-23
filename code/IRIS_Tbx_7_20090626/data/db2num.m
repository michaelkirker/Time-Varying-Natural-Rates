function [array,range,comment,source] = db2num(d,list,range)
%
% <a href="data/db2num">DB2NUM</a>  Convert selected times series from database to numeric array.
%
% Syntax:
%   [x,range] = db2num(d,list,dat)
% Required input arguments:
%   x [ numeric ] Matrix with time series stacked in columns.
%   list [ cellstr ] List of times series.
%   dat [ numeric ] Dates or range (IRIS serial date numbers).
%
% The IRIS Toolbox 2007/07/12. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 3, range = Inf; end
if ~isstruct(d) || ~iscellstr(list) || (~isnumeric(range) && ~ischar(range))
  error('Incorrect type of input argument(s).');
end

% function body ---------------------------------------------------------------------------------------------

if nargin < 3, range = 'max'; end

if isnumeric(list) && all(isinf(list)), list = dbobjects(d,'tseries');
  elseif isa(list,'char'), list = {list}; end

x = [];
invalid = cell([1,0]);
for i = 1 : length(list)
  try, x = [x,d.(list{i})];
    catch, invalid{end+1} = list{i}; end
end

if ~isempty(invalid)
  warning_(7,invalid);
end

[array,range,cmt] = double(x,range);

end % of primary function -----------------------------------------------------------------------------------