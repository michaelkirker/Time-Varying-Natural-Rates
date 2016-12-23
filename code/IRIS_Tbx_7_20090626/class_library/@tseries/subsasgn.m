function x = subsasgn(x,s,y)
% SUBSASGN  Subscripted assignment function for tseries objects.
%
% Syntax:
%   x(dates) = ...
%   x(dates,...) = ...
%   x.comment = ...
%   x.comment{...} = ...
%   x.comment(...) = ...
% Output arguments:
%   x [ tseries ] Time series with newly assigned values.
% Required input arguments:
%   dates [ numeric ] Dates or time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2009/01/16.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Variable Editor's calling SUBSASGN cannot be distinguish from a regular
% assignment in the workspace (i.e. we cannot judge the call by dbstack).
% We try to guess whether this is a call from Variable Editor based on the
% 1st dimension's subscripts. This, however, cannot work for indeterminate
% frequencies.
if isVariableEditor_(x,s)
   x = variableEditor_('subsasgn',x,s,y);
   return
end
%&& all(s.subs{1} <= tmpsize(1)) && all(s.subs{2} <= tmpsize(2))

% x must exist as a tseries object
if ~istseries(x)
   error('iris:tseries','Invalid time series subscripted assignment.');
end

if strcmp(s(1).type,'.') && strcmpi(s(1).subs,'comment')
   comment_();
else
   roundbrks_();
end
% End of function body.

%********************************************************************
%! Nested function comment_().

   function comment_()
      if length(s) == 1
         x.comment = y;
      else
         x.comment = subsasgn(x.comment,s(2:end),y);
      end
      si = size(x.data);
      if ~iscellstr(x.comment)
         error('Comments must be cell arrays of strings.');
      elseif ndims(x.comment) ~= ndims(x.data) || any(size(x.comment) ~= [1,si(2:end)])
         error('Invalid size of comment array.');
      end
   end
% End of nested function comment_().

%********************************************************************
%! Nested function roundbrks_().

   function roundbrks_()
      [flag,x,s,shift,range] = subscript_(x,s);
      if ~flag
         error('iris:tseries','Invalid time series subscripted assignment.');
      end
      % Convert RHS time series to matrix.
      if istseries(y)
         y = subsref(y,struct('type','()','subs',{{range}}));
      end
      % If y has only one row but multiple rows (or other dims)
      % tseries is multivariate, and assigned are multiple dates
      % expand y in 1st dimension.
      tmpsize = size(x.data);
      if length(y) > 1 && size(y,1) == 1 && length(s.subs{1}) > 1 && any(tmpsize(2:end) > 1)
         n = length(s.subs{1});
         tmpsize = size(y);
         y = reshape(y(ones([1,n]),:),[n,tmpsize(2:end)]);
      end
      x.data = subsasgn(x.data,s,y);
      % Some columns may have been added or deleted.
      % Add or delete comments accordingly.
      x = resizeComments_(x);
      % Shift startdate back if there's been {} called.
      if shift ~= 0
         x.start = x.start + shift;
      end
      x = cut_(x);
   end
% End of nested function roundbrks_().

end
% End of primary function.