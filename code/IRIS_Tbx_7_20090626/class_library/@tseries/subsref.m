function y = subsref(x,s)
% SUBSREF  Subscripted reference function for tseries objects.
%
% Syntax:
%   x(dates)
%   x{dates}
%   x(dates,...)
%   x{dates,...}
%   x.comment
%   x.comment(...)
%   x.comment{...}
% Output arguments:
%   x [ tseries ] Referenced time series.
% Required input arguments:
%   dates [ numeric ] Dates or time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2009/01/16.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.
% Call from variable editor 2008b or higher.
if isVariableEditor_(x,s)
   y = variableEditor_('subsref',x,s);
   return
end

if strcmp(s(1).type,'.') && strcmpi(s(1).subs,'comment')
   comment_();
else
   [flag,x,s,shift,range] = subscript_(x,s);
   if ~flag
      error('iris:tseries','Invalid time series subscripted assignment.');
   end
   if strcmp(s(1).type,'()')
      roundbrks_();
   else
      curlybrks_();
   end
end
% End of function body.

%********************************************************************
%! Nested function comment_().

   function comment_()
      if length(s) == 1
         y = x.comment;
      else
         y = subsref(x.comment,s(2:end));
      end
   end
   % End of nested function comment_().

%********************************************************************
%! nested function roundbrks_()

   function roundbrks_()
      y = subsref(x.data,s);
   end
   % End of nested function roundbrks_().

%********************************************************************
%! nested function curlybrks_()

   function curlybrks_()
      s(1).type = '()';
      y = x;
      if ~isempty(range)
          y.start = range(1);
      else
          y.start = NaN;
      end
      y.data = subsref(y.data,s);
      s.subs{1} = 1;
      y.comment = subsref(y.comment,s);
      y = cut_(y);
   end
   % End of nested function curlybrks_().
   
end
% End of primary function.