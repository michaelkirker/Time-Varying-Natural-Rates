function range = setrange(range,infrange)
%
% The IRIS Toolbox 4/11/2007. Copyright 2007 Jaromir Benes.

% function body ---------------------------------------------------------------------------------------------

if isinf1(range) && nargin > 1
  range = infrange;
  return
end

if ~isinf1(range) && ~isempty(range)
  range = range(1) : range(end);
end

end % of primary function -----------------------------------------------------------------------------------