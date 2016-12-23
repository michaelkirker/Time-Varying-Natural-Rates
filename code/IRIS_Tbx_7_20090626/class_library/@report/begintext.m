function x = begintext(x,varargin)
%
% BEGINTEXT  Start text section in report.
%
% Syntax:
%   x = begintext(x,...)
% Required input arguments:
%   x report
%
% See also reportoptions.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

chksyntax_(x.parenttype{end},'begintext');
x.contents{end+1} = reportobject_('begintext',NaN,x.parentoptions{end},'linestretch',1,varargin{:});
x.parenttype{end+1} = 'begintext';
x.parentoptions{end+1} = x.contents{end}.options;
x.parentspec{end+1} = NaN;

end % of primary function -----------------------------------------------------------------------------------