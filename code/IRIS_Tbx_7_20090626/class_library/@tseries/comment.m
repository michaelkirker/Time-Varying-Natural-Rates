function x = comment(x,cmt)
% COMMENT  Set or get time series comment.

% The IRIS Toolbox 2009/04/14.
% Copyright 2007-2009 Jaromir Benes.

if nargin > 1 && ~ischar(cmt) && ~iscellstr(cmt)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

if nargin < 2
   % Get comments.
   if length(x.comment) == 1
      x = x.comment{1};
   else
      x = x.comment;
   end
else
  % Set comments.
   cmt = strrep(cmt,'"','');
   if ischar(cmt)
      x.comment(:) = {cmt};
   else
      x.comment(:) = cmt(:);
   end
end

end
% End of primary function.
