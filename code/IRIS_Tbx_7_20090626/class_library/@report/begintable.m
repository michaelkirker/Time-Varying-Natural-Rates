function x = begintable(x,varargin)
%
% BEGINTABLE  Start new table in report.
%
% Syntax:
%   x = begintable(x,...)
% Required input arguments:
%   x report
% <a href="options.html">Optional input arguments:</a> (begintable-specific options)
%   'range' numeric (empty)
%
% See also reportoptions.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if not(iscellstr(varargin(1:2:end))), error('Incorrect type of input argument(s).'); end

% function body ---------------------------------------------------------------------------------------------

chksyntax_(x.parenttype{end},'begintable');
x.contents{end+1} = reportobject_('begintable',NaN,x.parentoptions{end},varargin{:});
x.parenttype{end+1} = 'begintable';
x.parentoptions{end+1} = x.contents{end}.options;
x.parentspec{end+1} = NaN;

end % of primary function -----------------------------------------------------------------------------------