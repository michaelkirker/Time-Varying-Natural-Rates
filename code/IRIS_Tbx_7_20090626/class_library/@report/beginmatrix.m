function x = beginmatrix(x,varargin)
%
% BEGINMATRIX  Start new matrix in report.
%
% Syntax:
%   p = beginmatrix(p,...)
% Required input arguments:
%   p report
% Options (only beginmatrix specific options):
%   'hdivider' numeric (empty)
%   'hframe' logical (true)
%   'vdivider' numeric (empty)
%   'vframe' logical (true)
%
% See also reportoptions.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

chksyntax_(x.parenttype{end},'beginmatrix');
x.contents{end+1} = reportobject_('beginmatrix',NaN,x.parentoptions{end},varargin{:});
x.parenttype{end+1} = 'beginmatrix';
x.parentoptions{end+1} = x.contents{end}.options;
x.parentspec{end+1} = NaN;

end % of primary function -----------------------------------------------------------------------------------