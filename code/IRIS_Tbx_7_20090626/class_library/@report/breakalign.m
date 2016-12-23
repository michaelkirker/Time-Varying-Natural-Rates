function x = breakalign(x)
%
% BREAKALIGN  Start new row of horizontally aligned objects.
%
% Syntax:
%   x = breakalign(x)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

chksyntax_(x.parenttype{end},'breakalign');
x.contents{end+1} = reportobject_('breakalign');

end % of primary function -----------------------------------------------------------------------------------