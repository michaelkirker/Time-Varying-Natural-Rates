function [y,range] = getdata(p,varargin)
% GETDATA  Get numeric data for VAR from different types of input arguments.

% The IRIS Toolbox 2008/09/25.
% Copyright (c) 2007-2008 Jaromir Benes.

valid = true;
if istseries(varargin{1})
   % Time series.
   if length(varargin) == 2 && ~isnumeric(varargin{2})
      valid = false;
   end
elseif isstruct(varargin{1})
   % Database.
   if length(varargin) < 3 || (~ischar(varargin{2}) && ~iscellstr(varargin{2})) || ~isnumeric(varargin{3})
      valid = false;
   end
end
if ~valid
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

if isnumeric(varargin{1})
   % Numeric array.
   y = permute(varargin{1},[2,1,3]);
   range = 1 : size(y,2);
   varargout = varargin(2:end);
elseif istseries(varargin{1})
   % Time series.
   % Range is Inf if not specified by user.
   if length(varargin) < 2
      varargin{2} = Inf;
   end
   if all(isinf(varargin{2}))
      range = 'min';
   else
      range = varargin{2}(1)-p : varargin{2}(end);
   end
   [y,range] = double(varargin{1},range);
   y = permute(y,[2,1,3]);
   varargout = varargin(3:end);
elseif isstruct(varargin{1})
   % Database.
   list = varargin{2};
   if ischar(list)
      list = charlist2cellstr(list);
   end
   y = [];
   for i = 1 : numel(list)
      y = [y,permute(varargin{1}.(list{i}),[1,3,2])];
   end
   if all(isinf(varargin{3}))
      range = 'min';
   else
      range = varargin{3}(1)-p : varargin{3}(end);
   end
   [y,range] = double(y,range);
   y = permute(y,[2,1,3]);
   varargout = varargin(4:end);
end

end
% End of primary function.