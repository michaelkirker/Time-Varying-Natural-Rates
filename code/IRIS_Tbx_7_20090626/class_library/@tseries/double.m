function [data,dates,cmt] = double(x,dates)
%
% <a href="matlab: edit tseries/double">DOUBLE</a>  Convert tseries object to numeric array.
%
% Syntax:
%   [y,dates,cmt] = double(x)         (1)
%   [y,dates,cmt] = double(x,dates)   (2)
% Output argument:
%   y [ numeric ] Numeric array.
%   dates [ numeric ] Actually used dates, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%   cmt [ cellstr | char ] Comments.
% Required input arguments:
%   x [ tseries ] Time series to be converted.
% Required input arguments for syntax (2):
%   dates [ numeric ] Dates or range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 2
   dates = 'max';
end

if isnumeric(dates) && any(isinf(dates))
   dates = 'min';
end

if nargin > 1 && ~isa(dates,'char') && ~isa(dates,'function_handle') && ~isnumeric(dates)
   error('Incorrect type of input argument(s).');
end

% ###########################################################################################################
%% function body

if ischar(dates)
   switch dates
   case {'min','i','intersection'}
      [data,dim,nper] = reshape_(x.data);
      dates = x.start : x.start + nper - 1;
      index = any(isnan(data),2);
      data(index,:) = [];
      dates(index) = [];
      data = reshape_(data,dim);
   case {'max','u','union'}
      dates = x.start : x.start + size(x.data,1) - 1;
      data = x.data;
   otherwise
      error('Invalid dates/range specification');
   end
else
   dates = vech(dates);
   data = getdata_(x,dates);
end

if nargout > 2
   cmt = x.comment;
end

end
% end of primary function