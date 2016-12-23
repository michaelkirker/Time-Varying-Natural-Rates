function x = beginalign(x,varargin)
%
% BEGINALIGN  Start section of horizontally aligned objects.
%
% Syntax:
%   x = beginalign(x,...)
% Required input arguments:
%   x report
% <a href="options.html">Optional input arguments:</a> (only beginalign-specific options)
%   'horizontal' numeric (3) Number of objects to be horizontally aligned.
%
% See also reportoptions.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if not(iscellstr(varargin(1:2:end))), error('Incorrect type of input argument(s).'); end

% function body ---------------------------------------------------------------------------------------------

chksyntax_(x.parenttype{end},'beginalign');
x.contents{end+1} = reportobject_('beginalign',NaN,x.parentoptions{end},varargin{:});
x.parenttype{end+1} = 'beginalign';
x.parentoptions{end+1} = x.contents{end}.options;
x.parentspec{end+1} = NaN;

end % of primary function -----------------------------------------------------------------------------------